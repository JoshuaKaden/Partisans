//
//  NetPlayerHandler.m
//  Partisans
//
//  Created by Joshua Kaden on 8/4/15.
//  Copyright © 2015 Chadford Software. All rights reserved.
//

#import "NetPlayerHandler.h"

#import "CreateGameOperation.h"
#import "GameEnvoy.h"
#import "GamePrecis.h"
#import "JSKDataMiner.h"
#import "NetworkManager.h"
#import "NSManagedObjectContext+FetchAdditions.h"
#import "PlayerEnvoy.h"
#import "UpdateEnvoysOperation.h"
#import "UpdateGameOperation.h"
#import "UpdatePlayerOperation.h"
#import "SystemMessage.h"

@interface NetPlayerHandler ()
@property (nonatomic, strong) NSDictionary *playerDigest;
@end

@implementation NetPlayerHandler

- (BOOL)isDigestCurrent
{
    // Loop through the player digest and see if our saved Player data is up-to-date.
    BOOL returnValue = YES;
    NSDictionary *digest = self.playerDigest;
    for (NSString *otherID in digest.allKeys)
    {
        NSDate *otherDate = [digest valueForKey:otherID];
        PlayerEnvoy *otherEnvoy = [PlayerEnvoy envoyFromPeerID:otherID];
        if (!otherEnvoy)
        {
            returnValue = NO;
            break;
        }
        if ([SystemMessage secondsBetweenDates:otherEnvoy.modifiedDate toDate:otherDate] != 0)
        {
            returnValue = NO;
            break;
        }
    }
    return returnValue;
}

- (void)handleJoinGameResponse:(JSKCommandParcel *)response
{
    if (!response.object)
    {
        return;
    }
    if (![response.object isKindOfClass:[GameEnvoy class]])
    {
        return;
    }
    
    [SystemMessage sharedInstance].isLookingForGame = NO;
    
    // Save the game locally.
    GameEnvoy *envoy = (GameEnvoy *)response.object;
    CreateGameOperation *op = [[CreateGameOperation alloc] initWithEnvoy:envoy];
    [op setCompletionBlock:^(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Once the save is done, update our own gameEnvoy property.
            NSManagedObjectContext *context = [JSKDataMiner mainObjectContext];
            NSArray *games = [context fetchObjectArrayForEntityName:@"Game" withPredicateFormat:@"intramuralID == %@", envoy.intramuralID];
            if (games.count > 0)
            {
                GameEnvoy *updatedEnvoy = [GameEnvoy envoyFromManagedObject:[games objectAtIndex:0]];
                [[SystemMessage sharedInstance] setGameEnvoy:updatedEnvoy];
                
                // Also, post a notification that we joined the game.
                [[NSNotificationCenter defaultCenter] postNotificationName:kPartisansNotificationJoinedGame object:updatedEnvoy];
            }
        });
    }];
    NSOperationQueue *queue = [SystemMessage mainQueue];
    [queue addOperation:op];
}


- (void)handleHostAcknowledgement:(JSKCommandMessage *)message
{
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       [[NSNotificationCenter defaultCenter] postNotificationName:kPartisansNotificationHostAcknowledgement object:message.responseKey];
                   });
}

#pragma mark - NetPlayer delegate

- (NSString *)netPlayerPeerID:(NetPlayer *)netPlayer
{
    return self.playerEnvoy.peerID;
}

- (NSDate *)netPlayerModifiedDate:(NetPlayer *)netPlayer
{
    return self.playerEnvoy.modifiedDate;
}

- (void)netPlayer:(NetPlayer *)netPlayer receivedCommandMessage:(JSKCommandMessage *)commandMessage
{
    PlayerEnvoy *playerEnvoy = self.playerEnvoy;
    JSKCommandMessageType messageType = commandMessage.commandMessageType;
    NSObject <NSCoding> *responseObject = nil;
    BOOL shouldAwaitResponse = NO;
    
    switch (messageType)
    {
        case JSKCommandMessageTypeAcknowledge:
            [self handleHostAcknowledgement:commandMessage];
            break;
        case JSKCommandMessageTypeGetInfo:
            responseObject = playerEnvoy;
            break;
        case JSKCommandMessageTypeGetModifiedDate:
            responseObject = playerEnvoy.modifiedDate;
            break;
            //        case JSKCommandMessageTypeIdentification:
            //            // We'll get this back from a host after sending them our ID.
            //            // Send the host our player data.
            //            // In return, the host will send us their data.
            //            responseObject = playerEnvoy;
            //            shouldAwaitResponse = YES;
            //            break;
        default:
            debugLog(@"Unexpected message type from host: %@", commandMessage);
            break;
    }
    
    if (responseObject)
    {
        JSKCommandParcel *response = [[JSKCommandParcel alloc] initWithType:JSKCommandParcelTypeResponse
                                                                         to:commandMessage.from
                                                                       from:playerEnvoy.peerID
                                                                     object:responseObject
                                                                responseKey:commandMessage.responseKey];
        [netPlayer sendCommandParcel:response shouldAwaitResponse:shouldAwaitResponse];
    }
}

- (void)netPlayer:(NetPlayer *)netPlayer receivedCommandParcel:(JSKCommandParcel *)commandParcel
{
    NSObject *object = commandParcel.object;
    if (commandParcel.commandParcelType == JSKCommandParcelTypeDigest)
    {
        // This means that the object is a dictionary of Player.modifiedDate values, keyed on peerID.
        NSDictionary *digest = (NSDictionary *)object;
        self.playerDigest = digest;
        [self processDigest:digest];
        return;
    }
    
    // Save the player data locally.
    if ([object isKindOfClass:[PlayerEnvoy class]])
    {
        PlayerEnvoy *other = (PlayerEnvoy *)object;
        other.isNative = NO;
        other.isDefault = NO;
        [SystemMessage clearImageCache];
        
        UpdatePlayerOperation *op = [[UpdatePlayerOperation alloc] initWithEnvoy:other];
        [op setCompletionBlock:^(void){
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([SystemMessage sharedInstance].isLookingForGame)
                {
                    if ([self isDigestCurrent])
                    {
                        [NetworkManager askToJoinGameHostedBy:other.peerID];
                    }
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kJSKNotificationPeerUpdated object:other.peerID];
            });
        }];
        NSOperationQueue *queue = [SystemMessage mainQueue];
        [queue addOperation:op];
        return;
    }
    
    // Save the Game data locally.
    if ([object isKindOfClass:[GameEnvoy class]])
    {
        // Let's make sure the copy we're getting is newer than the one we have currently.
        GameEnvoy *currentGame = self.gameEnvoy;
        if (!currentGame)
        {
            return;
        }
        GameEnvoy *updatedGame = (GameEnvoy *)commandParcel.object;
        
        if (![currentGame.intramuralID isEqualToString:updatedGame.intramuralID])
        {
            return;
        }
        
        if (currentGame.modifiedDate && updatedGame.modifiedDate)
        {
            NSInteger delta = [SystemMessage secondsBetweenDates:currentGame.modifiedDate toDate:updatedGame.modifiedDate];
            if (delta <= 0)
            {
                return;
            }
        }
        
        updatedGame.hasScoreBeenShown = YES;
        
        UpdateGameOperation *op = [[UpdateGameOperation alloc] initWithEnvoy:updatedGame];
        [op setCompletionBlock:^(void){
            dispatch_async(dispatch_get_main_queue(), ^(void)
                           {
                               updatedGame.hasScoreBeenShown = YES;
                               [[SystemMessage sharedInstance] setGameEnvoy:updatedGame];
                               [[NSNotificationCenter defaultCenter] postNotificationName:kPartisansNotificationGameChanged object:nil];
                           });
        }];
        NSOperationQueue *queue = [SystemMessage mainQueue];
        [queue addOperation:op];
        return;
    }
    
    
    // Save the envoys locally.
    if ([object isKindOfClass:[NSArray class]])
    {
        GameEnvoy *currentGame = self.gameEnvoy;
        if (!currentGame)
        {
            return;
        }
        NSArray *envoys = (NSArray *)commandParcel.object;
        
        GamePrecis *precis = (GamePrecis *)[envoys objectAtIndex:0];
        if (!precis)
        {
            return;
        }
        if (currentGame.modifiedDate && precis.modifiedDate)
        {
            NSInteger delta = [SystemMessage secondsBetweenDates:currentGame.modifiedDate toDate:precis.modifiedDate];
            if (delta <= 0)
            {
                return;
            }
        }
        
        UpdateEnvoysOperation *op = [[UpdateEnvoysOperation alloc] initWithEnvoys:envoys];
        [op setCompletionBlock:^(void)
         {
             dispatch_async(dispatch_get_main_queue(), ^(void)
                            {
                                [SystemMessage reloadGame:currentGame];
                                [[NSNotificationCenter defaultCenter] postNotificationName:kPartisansNotificationGameChanged object:nil];
                            });
         }];
        NSOperationQueue *queue = [SystemMessage mainQueue];
        [queue addOperation:op];
        return;
    }
}


- (void)netPlayer:(NetPlayer *)netPlayer receivedCommandParcel:(JSKCommandParcel *)commandParcel respondingTo:(NSObject<NSCoding> *)inResponseTo
{
    if ([inResponseTo isKindOfClass:[JSKCommandMessage class]]) {
        JSKCommandMessage *message = (JSKCommandMessage *)inResponseTo;
        if (message.commandMessageType == JSKCommandMessageTypeJoinGame) {
            [self handleJoinGameResponse:commandParcel];
            return;
        }
    }
    [self netPlayer:netPlayer receivedCommandParcel:commandParcel];
}

- (void)netPlayer:(NetPlayer *)netPlayer terminated:(NSString *)reason
{
    [netPlayer stop];
    //    debugLog(@"NetPlayer terminated: %@", reason);
}

- (void)netPlayerDidResolveAddress:(NetPlayer *)netPlayer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kPartisansNotificationConnectedToHost object:nil];
    });
    [NetworkManager sendToHost:JSKCommandMessageTypeIdentification shouldAwaitResponse:YES];
}

@end
