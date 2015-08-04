//
//  NetHandler.m
//  Partisans
//
//  Created by Joshua Kaden on 8/4/15.
//  Copyright © 2015 Chadford Software. All rights reserved.
//

#import "NetHandler.h"

#import "GameEnvoy.h"
#import "JSKCommandMessage.h"
#import "JSKCommandParcel.h"
#import "NetworkManager.h"
#import "PlayerEnvoy.h"
#import "SystemMessage.h"
#import "UpdatePlayerOperation.h"

@interface NetHandler ()
@end

@implementation NetHandler

- (GameEnvoy *)gameEnvoy
{
    return [SystemMessage gameEnvoy];
}

- (NSString *)myPeerID
{
    return [SystemMessage playerEnvoy].peerID;
}

- (PlayerEnvoy *)playerEnvoy
{
    return [SystemMessage sharedInstance].playerEnvoy;
}

- (void)sendDigestTo:(NSString *)toPeerID
{
    NSDictionary *digest = [self buildDigestFor:toPeerID];
    JSKCommandParcel *parcel = [[JSKCommandParcel alloc] initWithType:JSKCommandParcelTypeDigest
                                                                   to:toPeerID
                                                                 from:self.myPeerID
                                                               object:digest
                                                          responseKey:nil];
    [NetworkManager sendCommandParcel:parcel shouldAwaitResponse:NO];
}

- (NSDictionary *)buildDigestFor:(NSString *)forPeerID
{
    NSArray *gamePlayers = [[SystemMessage gameEnvoy] players];
    NSMutableDictionary *digest = [[NSMutableDictionary alloc] initWithCapacity:gamePlayers.count];
    for (PlayerEnvoy *player in gamePlayers) {
        if (![player.peerID isEqualToString:forPeerID]) {
            [digest setValue:player.modifiedDate forKey:player.peerID];
        }
    }
    NSDictionary *returnValue = [NSDictionary dictionaryWithDictionary:digest];
    return returnValue;
}

- (void)processDigest:(NSDictionary *)digest
{
    // Crash prevention when hosting after joining.
    if (digest.count == 0) {
        return;
    }
    
    BOOL wasNewDataRequested = NO;
    // The digest is a dictionary of Player.modifiedDate values, keyed on peerID.
    PlayerEnvoy *playerEnvoy = [SystemMessage playerEnvoy];
    for (NSString *otherID in digest.allKeys) {
        BOOL shouldAskForData = NO;
        NSDate *otherDate = [digest valueForKey:otherID];
        if (otherDate) {
            PlayerEnvoy *otherEnvoy = [PlayerEnvoy envoyFromPeerID:otherID];
            if (otherEnvoy) {
                if ([SystemMessage secondsBetweenDates:otherEnvoy.modifiedDate toDate:otherDate] > 0 || [otherEnvoy.modifiedDate isEqualToDate:[NSDate distantPast]]) {
                    shouldAskForData = YES;
                }
            } else {
                shouldAskForData = YES;
            }
        }
        
        if (shouldAskForData) {
            // If we are a Host, then the dictionary will contain one row, and we'll send the message to that Player.
            // If we are a Player, the "to" field will not necessarily be the Host's address. But we'll be sending the message to the Host.
            // Note the use of the "to" field here, to indicate that we're interested in that player's info, not (necessarily) the recipient's.
            JSKCommandMessage *message = [[JSKCommandMessage alloc] initWithType:JSKCommandMessageTypeGetInfo to:otherID from:playerEnvoy.peerID];
            [NetworkManager sendCommandMessage:message shouldAwaitResponse:YES];
            wasNewDataRequested = YES;
        }
    }
    
    if (!wasNewDataRequested) {
        if ([SystemMessage isHost]) {
            NSString *otherID = [digest.allKeys objectAtIndex:0];
            [self sendDigestTo:otherID];
        } else {
            if ([SystemMessage sharedInstance].isLookingForGame) {
                [NetworkManager askToJoinGame];
            } else {
                if (self.gameEnvoy) {
                    [SystemMessage requestGameUpdate];
                }
            }
        }
    }
}

- (void)handlePlayerUpdate:(JSKCommandParcel *)parcel
{
    NSObject *object = parcel.object;
    if ([object isKindOfClass:[PlayerEnvoy class]])
    {
        PlayerEnvoy *other = (PlayerEnvoy *)object;
        other.isNative = NO;
        other.isDefault = NO;
        
        //        BOOL isHost = [SystemMessage isHost];
        
        UpdatePlayerOperation *op = [[UpdatePlayerOperation alloc] initWithEnvoy:other];
        [op setCompletionBlock:^(void)
         {
             //            if (isHost)
             //            {
             //                [self broadcastPlayerData:other.peerID];
             //            }
             // Update the UI.
             dispatch_async(dispatch_get_main_queue(), ^{
                 [[NSNotificationCenter defaultCenter] postNotificationName:kJSKNotificationPeerUpdated object:other.peerID];
             });
         }];
        NSOperationQueue *queue = [SystemMessage mainQueue];
        [queue addOperation:op];
    }
}

@end
