//
//  NetHostHandler.m
//  Partisans
//
//  Created by Joshua Kaden on 8/3/15.
//  Copyright © 2015 Chadford Software. All rights reserved.
//

#import "NetHostHandler.h"

#import "AddGamePlayerOperation.h"
#import "CoordinatorVote.h"
#import "GameDirector.h"
#import "GameEnvoy.h"
#import "JSKCommandMessageProtocol.h"
#import "JSKCommandParcel.h"
#import "MissionEnvoy.h"
#import "NetworkManager.h"
#import "PlayerEnvoy.h"
#import "RemoveGamePlayerOperation.h"
#import "RoundEnvoy.h"
#import "SystemMessage.h"
#import "UpdateGameOperation.h"
#import "UpdatePlayerOperation.h"
#import "VoteEnvoy.h"

@interface NetHostHandler ()
@end

@implementation NetHostHandler

- (JSKCommandMessage *)buildAcknowledgementFromMessage:(id<JSKCommandMessageProtocol>)message
{
    JSKCommandMessage *acknowledgement = [[JSKCommandMessage alloc] initWithType:JSKCommandMessageTypeAcknowledge to:message.from from:self.myPeerID];
    acknowledgement.responseKey = message.responseKey;
    return acknowledgement;
}

- (void)handlePlayerResponse:(JSKCommandParcel *)commandParcel inResponseTo:(JSKCommandMessage *)inResponseTo
{
    // This could be a response to a GetInfo message.
    if (inResponseTo.commandMessageType == JSKCommandMessageTypeGetInfo) {
        // In this case we expect a PlayerEnvoy.
        PlayerEnvoy *otherEnvoy = (PlayerEnvoy *)commandParcel.object;
        otherEnvoy.isNative = NO;
        otherEnvoy.isDefault = NO;
        
        UpdatePlayerOperation *op = [[UpdatePlayerOperation alloc] initWithEnvoy:otherEnvoy];
        [op setCompletionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self sendDigestTo:commandParcel.from];
                [[NSNotificationCenter defaultCenter] postNotificationName:kJSKNotificationPeerUpdated object:otherEnvoy.peerID];
            });
        }];
        NSOperationQueue *queue = [SystemMessage mainQueue];
        [queue addOperation:op];
    } else {
        // no op
    }
}

// Send the player's data to everyone but the player (who already knows it), and the host (who is me).
- (void)broadcastPlayerData:(NSString *)peerID
{
    PlayerEnvoy *envoy = [PlayerEnvoy envoyFromPeerID:peerID];
    NSArray *gamePlayers = [[SystemMessage gameEnvoy] players];
    for (PlayerEnvoy *player in gamePlayers) {
        if (![player.peerID isEqualToString:peerID] && ![player.peerID isEqualToString:self.myPeerID]) {
            JSKCommandParcel *parcel = [[JSKCommandParcel alloc] initWithType:JSKCommandParcelTypeUpdate to:player.peerID from:self.myPeerID object:envoy];
            [NetworkManager sendCommandParcel:parcel shouldAwaitResponse:NO];
        }
    }
}

- (void)handleJoinGameMessage:(JSKCommandMessage *)message
{
    PlayerEnvoy *other = [PlayerEnvoy envoyFromPeerID:message.from];
    if (!other || !other.playerName || other.playerName.length == 0) {
        debugLog(@"invalid join game message")
        return;
    }
    [self addPlayerToGame:other responseKey:message.responseKey];
}

- (void)addPlayerToGame:(PlayerEnvoy *)playerEnvoy responseKey:(NSString *)responseKey
{
    BOOL proceed = NO;
    if ([SystemMessage isHost]) {
        // We are hosting a game.
        if (self.gameEnvoy.players.count < kPartisansMaxPlayers && !self.gameEnvoy.startDate) {
            // The game has room and hasn't yet started.
            // So, let the other player join, and send the game object back!
            proceed = YES;
        }
    }
    if (proceed) {
        // Make sure this player isn't already in the game.
        if ([self.gameEnvoy isPlayerInGame:playerEnvoy]) {
            [self sendGameUpdateTo:playerEnvoy.peerID modifiedDate:nil shouldSendAllData:YES];
            proceed = NO;
        }
    }
    
    if (!proceed) {
        return;
    }
    
    NSString *peerID = playerEnvoy.peerID;
    NSString *hostID = self.myPeerID;
    
    // Add this player to the game.
    AddGamePlayerOperation *op = [[AddGamePlayerOperation alloc] initWithPlayerEnvoy:playerEnvoy gameEnvoy:self.gameEnvoy];
    [op setCompletionBlock:^(void) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kPartisansNotificationGameChanged object:nil];
        });
        
         JSKCommandParcel *parcel = [[JSKCommandParcel alloc] initWithType:JSKCommandParcelTypeResponse to:peerID from:hostID object:self.gameEnvoy responseKey:responseKey];
        [NetworkManager sendCommandParcel:parcel shouldAwaitResponse:NO];
     }];
    NSOperationQueue *queue = [SystemMessage mainQueue];
    [queue addOperation:op];
}

- (void)sendGameUpdateTo:(NSString *)peerID modifiedDate:(NSDate *)modifiedDate shouldSendAllData:(BOOL)shouldSendAllData
{
    [[SystemMessage gameDirector] sendGameUpdateTo:peerID modifiedDate:modifiedDate shouldSendAllData:shouldSendAllData];
}


- (void)handleCoordinatorVote:(JSKCommandParcel *)parcel
{
    CoordinatorVote *coordinatorVote = (CoordinatorVote *)parcel.object;
    VoteEnvoy *voteEnvoy = coordinatorVote.voteEnvoy;
    voteEnvoy.isCast = YES;
    NSArray *candidateIDs = coordinatorVote.candidateIDs;
    
    JSKCommandMessage *acknowledgement = [self buildAcknowledgementFromMessage:parcel];
    
    RoundEnvoy *roundEnvoy = [self.gameEnvoy currentRound];
    for (NSString *candidateID in candidateIDs) {
        PlayerEnvoy *candidate = [PlayerEnvoy envoyFromIntramuralID:candidateID];
        [roundEnvoy addCandidate:candidate];
    }
    [roundEnvoy addVote:voteEnvoy];
    UpdateGameOperation *op = [[UpdateGameOperation alloc] initWithEnvoy:self.gameEnvoy];
    [op setCompletionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [NetworkManager sendCommandMessage:acknowledgement shouldAwaitResponse:NO];
        });
    }];
    NSOperationQueue *queue = [SystemMessage mainQueue];
    [queue addOperation:op];
}

- (void)handleVote:(JSKCommandParcel *)parcel
{
    VoteEnvoy *voteEnvoy = (VoteEnvoy *)parcel.object;
    voteEnvoy.isCast = YES;
    
    RoundEnvoy *roundEnvoy = [self.gameEnvoy currentRound];
    [roundEnvoy addVote:voteEnvoy];
    
    JSKCommandMessage *acknowledgement = [self buildAcknowledgementFromMessage:parcel];
    
    UpdateGameOperation *op = [[UpdateGameOperation alloc] initWithEnvoy:self.gameEnvoy];
    [op setCompletionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [SystemMessage reloadGame:self.gameEnvoy];
            [NetworkManager sendCommandMessage:acknowledgement shouldAwaitResponse:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:kPartisansNotificationGameChanged object:nil];
        });
    }];
    NSOperationQueue *queue = [SystemMessage mainQueue];
    [queue addOperation:op];
}

- (void)handlePerformMissionMessage:(JSKCommandMessage *)message
{
    MissionEnvoy *missionEnvoy = [self.gameEnvoy currentMission];
    PlayerEnvoy *from = [PlayerEnvoy envoyFromPeerID:message.from];
    if (message.commandMessageType == JSKCommandMessageTypeSucceed) {
        [missionEnvoy applyContributeur:from];
    } else if (message.commandMessageType == JSKCommandMessageTypeFail) {
        [missionEnvoy applySaboteur:from];
    } else {
        // Unexpected message type.
        debugLog(@"Unexpected message type");
        return;
    }
    
    JSKCommandMessage *acknowledgement = [self buildAcknowledgementFromMessage:message];
    
    UpdateGameOperation *op = [[UpdateGameOperation alloc] initWithEnvoy:self.gameEnvoy];
    [op setCompletionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [SystemMessage reloadGame:self.gameEnvoy];
            [NetworkManager sendCommandMessage:acknowledgement shouldAwaitResponse:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:kPartisansNotificationGameChanged object:nil];
        });
    }];
    NSOperationQueue *queue = [SystemMessage mainQueue];
    [queue addOperation:op];
}


- (void)handleLeaveGameMessage:(JSKCommandMessage *)message
{
    PlayerEnvoy *other = [PlayerEnvoy envoyFromPeerID:message.from];
    if (!other) {
        return;
    }
    // Make sure this player is in the game.
    if (![self.gameEnvoy isPlayerInGame:other]) {
        return;
    }
    
    // Remove this player from the game.
    RemoveGamePlayerOperation *op = [[RemoveGamePlayerOperation alloc] initWithEnvoy:other];
    [op setCompletionBlock:^(void) {
        JSKCommandParcel *gameParcel = [[JSKCommandParcel alloc] initWithType:JSKCommandParcelTypeUpdate to:nil from:self.myPeerID object:self.gameEnvoy];
        [NetworkManager sendParcelToPlayers:gameParcel];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kPartisansNotificationGameChanged object:nil];
        });
    }];
    NSOperationQueue *queue = [SystemMessage mainQueue];
    [queue addOperation:op];
}

#pragma mark - NetHost delegate

- (NSString *)netHostPeerID:(NetHost *)netHost
{
    return [SystemMessage playerEnvoy].peerID;
}

- (void)netHost:(NetHost *)netHost receivedCommandParcel:(JSKCommandParcel *)commandParcel
{
    switch (commandParcel.commandParcelType) {
        case JSKCommandParcelTypeDigest:
            // A player will not send this.
            break;
            
        case JSKCommandParcelTypeModifiedDate: {
            NSString *otherID = commandParcel.from;
            NSDictionary *dictionary = (NSDictionary *)commandParcel.object;
            NSString *entity = [dictionary valueForKey:@"entity"];
            NSDate *otherDate = [dictionary valueForKey:@"modifiedDate"];
            BOOL shouldSendAllData = [[dictionary valueForKey:@"shouldSendAllData"] boolValue];
            if ([entity isEqualToString:@"Player"]) {
                [self processDigest:[NSDictionary dictionaryWithObject:otherDate forKey:otherID]];
            } else if ([entity isEqualToString:@"Game"]) {
                [self sendGameUpdateTo:otherID modifiedDate:otherDate shouldSendAllData:shouldSendAllData];
            }
            break;
        }
            
        case JSKCommandParcelTypeResponse:
            break;
            
        case JSKCommandParcelTypeUpdate:
            if ([commandParcel.object isKindOfClass:[PlayerEnvoy class]]) {
                [self handlePlayerUpdate:commandParcel];
            }
            if ([commandParcel.object isKindOfClass:[CoordinatorVote class]]) {
                [self handleCoordinatorVote:commandParcel];
            }
            if ([commandParcel.object isKindOfClass:[VoteEnvoy class]]) {
                [self handleVote:commandParcel];
            }
            break;
            
        case JSKCommandParcelTypeUnknown:
            break;
            
        case JSKCommandParcelType_maxValue:
            break;
    }
}


- (void)netHost:(NetHost *)netHost receivedCommandParcel:(JSKCommandParcel *)commandParcel respondingTo:(NSObject<NSCoding> *)inResponseTo
{
    if ([inResponseTo isKindOfClass:[JSKCommandMessage class]]) {
        JSKCommandMessage *msg = (JSKCommandMessage *)inResponseTo;
        [self handlePlayerResponse:commandParcel inResponseTo:msg];
    }
    //    else if ([inResponseTo isKindOfClass:[JSKCommandParcel class]])
    //    {
    //        JSKCommandParcel *parcel = (JSKCommandParcel *)inResponseTo;
    //        [self handleResponse:commandParcel inResponseToParcel:parcel];
    //    }
}


- (void)netHost:(NetHost *)netHost receivedCommandMessage:(JSKCommandMessage *)commandMessage
{
    NSString *peerID = commandMessage.from;
    PlayerEnvoy *other = [PlayerEnvoy envoyFromPeerID:peerID];
    if (!other) {
        // Unidentified or unmatched player.
        debugLog(@"Message from unknown peer %@", commandMessage);
        return;
    }
    
    if (commandMessage.commandMessageType == JSKCommandMessageTypeJoinGame) {
        [self handleJoinGameMessage:commandMessage];
        return;
    }
    
    if (commandMessage.commandMessageType == JSKCommandMessageTypeGetDigest) {
        [self sendDigestTo:peerID];
        return;
    }
    
    // The "to" field tells us which player the sender is interested in.
    PlayerEnvoy *playerEnvoy = [PlayerEnvoy envoyFromPeerID:commandMessage.to];
    //    PlayerEnvoy *playerEnvoy = self.playerEnvoy;
    JSKCommandMessageType messageType = commandMessage.commandMessageType;
    //    JSKCommandParcelType parcelType = JSKCommandParcelTypeUnknown;
    NSObject <NSCoding> *responseObject = nil;
    
    switch (messageType) {
        case JSKCommandMessageTypeGetInfo:
            //            parcelType = JSKCommandParcelTypeResponse;
            responseObject = playerEnvoy;
            break;
        case JSKCommandMessageTypeGetModifiedDate:
            //            parcelType = JSKCommandParcelTypeResponse;
            responseObject = playerEnvoy.modifiedDate;
            break;
        case JSKCommandMessageTypeJoinGame:
            // This was caught above.
            //            [self handleJoinGameMessage:commandMessage];
            break;
        case JSKCommandMessageTypeIdentification: {
            // If not caught above then we already know about this player.
            // Let's get their data.
            JSKCommandMessage *msg = [[JSKCommandMessage alloc] initWithType:JSKCommandMessageTypeGetInfo to:commandMessage.from from:self.playerEnvoy.peerID];
            [NetworkManager sendCommandMessage:msg shouldAwaitResponse:YES];
            break;
        }
        case JSKCommandMessageTypeLeaveGame:
            [self handleLeaveGameMessage:commandMessage];
            break;
            
        case JSKCommandMessageTypeSucceed:
        case JSKCommandMessageTypeFail:
            [self handlePerformMissionMessage:commandMessage];
            break;
            
        default:
            break;
    }
    
    if (responseObject) {
        JSKCommandParcel *response = [[JSKCommandParcel alloc] initWithType:JSKCommandParcelTypeResponse
                                                                         to:peerID
                                                                       from:playerEnvoy.peerID
                                                                     object:responseObject
                                                                responseKey:commandMessage.responseKey];
        [netHost sendCommandParcel:response];
    }
}

- (void)netHost:(NetHost *)netHost terminated:(NSString *)reason
{
    debugLog(@"NetHost terminated: %@", reason);
}

@end
