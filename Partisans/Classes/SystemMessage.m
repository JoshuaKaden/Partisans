//
//  SystemMessage.m
//  Partisans
//
//  Created by Joshua Kaden on 4/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "SystemMessage.h"

#import "AddGamePlayerOperation.h"
#import "CreateGameOperation.h"
#import "CreatePlayerOperation.h"
#import "GameEnvoy.h"
#import "JSKCommandMessage.h"
#import "JSKCommandParcel.h"
#import "JSKDataMiner.h"
#import "NetHost.h"
#import "NetPlayer.h"
#import "NSManagedObjectContext+FetchAdditions.h"
#import "PlayerEnvoy.h"
#import "RemoveGamePlayerOperation.h"
#import "UpdateGameOperation.h"
#import "UpdatePlayerOperation.h"


const BOOL kIsDebugOn = YES;

NSString * const JSKNotificationPeerCreated = @"JSKNotificationPeerCreated";
NSString * const JSKNotificationPeerUpdated = @"JSKNotificationPeerUpdated";

NSUInteger const kPartisansMaxPlayers = 10;
NSUInteger const kPartisansMinPlayers = 5;

NSString * const kPartisansNotificationJoinedGame  = @"kPartisansNotificationJoinedGame";
NSString * const kPartisansNotificationGameChanged = @"kPartisansNotificationGameChanged";
NSString * const kPartisansNotificationConnectedToHost = @"kPartisansNotificationConnectedToHost";

NSString * const kPartisansNetServiceName = @"ThoroughlyRandomServiceNameForPartisans";


@interface SystemMessage () <NetHostDelegate, NetPlayerDelegate>

@property (nonatomic, strong) NetHost *netHost;
@property (nonatomic, strong) NetPlayer *netPlayer;
@property (nonatomic, strong) NSMutableArray *stash;
@property (nonatomic, strong) NSMutableArray *peerIDs;
@property (nonatomic, strong) NSDictionary *playerDigest;
@property (nonatomic, strong) NSString *hostPeerID;

- (void)handlePlayerResponse:(JSKCommandParcel *)commandParcel inResponseTo:(JSKCommandMessage *)inResponseTo;
- (void)handleResponse:(JSKCommandParcel *)commandParcel inResponseToParcel:(JSKCommandParcel *)inResponseToParcel;
- (void)handleModifiedDateResponse:(JSKCommandParcel *)response;
- (void)handleGetInfoResponse:(JSKCommandParcel *)response;
- (void)handleJoinGameMessage:(JSKCommandMessage *)message;
- (void)handleJoinGameResponse:(JSKCommandParcel *)response;
- (void)handleLeaveGameMessage:(JSKCommandMessage *)message;
- (void)handlePlayerUpdate:(JSKCommandParcel *)parcel;
- (void)handleJoinGameStash:(NSString *)fromPeerID;
- (void)addPlayerToGame:(PlayerEnvoy *)playerEnvoy responseKey:(NSString *)responseKey;
- (void)askToJoinGame:(NSString *)toPeerID;
- (BOOL)isReadyToJoinGame;
- (void)processDigest:(NSDictionary *)digest;
- (void)sendDigestTo:(NSString *)toPeerID;
- (NSDictionary *)buildDigestFor:(NSString *)forPeerID;
- (void)broadcastPlayerData:(NSString *)peerID;

@end



@implementation SystemMessage

@synthesize playerEnvoy = m_playerEnvoy;
@synthesize netHost = m_netHost;
@synthesize netPlayer = m_netPlayer;
@synthesize gameEnvoy = m_gameEnvoy;
@synthesize stash = m_stash;
@synthesize peerIDs = m_peerIDs;
@synthesize isLookingForGame = m_isLookingForGame;
@synthesize playerDigest = m_playerDigest;
@synthesize hostPeerID = m_hostPeerID;


- (void)dealloc
{
    [m_netHost setDelegate:nil];
    
    [m_playerEnvoy release];
    [m_netHost release];
    [m_netPlayer release];
    [m_gameEnvoy release];
    [m_stash release];
    [m_peerIDs release];
    [m_playerDigest release];
    [m_hostPeerID release];
    
    [super dealloc];
}



#pragma mark - Host

- (void)handlePlayerResponse:(JSKCommandParcel *)commandParcel inResponseTo:(JSKCommandMessage *)inResponseTo
{
    // This could be a response to a GetInfo message.
    if (inResponseTo.commandMessageType == JSKCommandMessageTypeGetInfo)
    {
        // In this case we expect a PlayerEnvoy.
        PlayerEnvoy *otherEnvoy = (PlayerEnvoy *)commandParcel.object;
        otherEnvoy.isNative = NO;
        otherEnvoy.isDefault = NO;
        
        UpdatePlayerOperation *op = [[UpdatePlayerOperation alloc] initWithEnvoy:otherEnvoy];
        [op setCompletionBlock:^(void){
            [self sendDigestTo:commandParcel.from];
            [self broadcastPlayerData:commandParcel.from];
            // Update the UI.
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:JSKNotificationPeerUpdated object:otherEnvoy.peerID];
            });
        }];
        NSOperationQueue *queue = [SystemMessage mainQueue];
        [queue addOperation:op];
        [op release];
        return;
    }
}

- (void)sendDigestTo:(NSString *)toPeerID
{
    NSDictionary *digest = [self buildDigestFor:toPeerID];
    JSKCommandParcel *parcel = [[JSKCommandParcel alloc] initWithType:JSKCommandParcelTypeDigest
                                                                   to:toPeerID
                                                                 from:self.playerEnvoy.peerID
                                                               object:digest
                                                          responseKey:nil];
    [self.netHost sendCommandParcel:parcel];
    [parcel release];
}

- (NSDictionary *)buildDigestFor:(NSString *)forPeerID
{
    NSArray *gamePlayers = [self.gameEnvoy players];
    NSMutableDictionary *digest = [[NSMutableDictionary alloc] initWithCapacity:gamePlayers.count];
    for (PlayerEnvoy *player in gamePlayers)
    {
        if (![player.peerID isEqualToString:forPeerID])
        {
            [digest setValue:player.modifiedDate forKey:player.peerID];
        }
    }
    NSDictionary *returnValue = [NSDictionary dictionaryWithDictionary:digest];
    [digest release];
    return returnValue;
}

- (void)broadcastPlayerData:(NSString *)peerID
{
    PlayerEnvoy *envoy = [PlayerEnvoy envoyFromPeerID:peerID];
    NSArray *gamePlayers = [self.gameEnvoy players];
    for (PlayerEnvoy *player in gamePlayers)
    {
        if (![player.peerID isEqualToString:peerID] && ![player.peerID isEqualToString:self.playerEnvoy.peerID])
        {
            JSKCommandParcel *parcel = [[JSKCommandParcel alloc] initWithType:JSKCommandParcelTypeUpdate to:player.peerID from:self.playerEnvoy.peerID object:envoy];
            [self.netHost sendCommandParcel:parcel];
            [parcel release];
        }
    }
}

- (void)handleJoinGameMessage:(JSKCommandMessage *)message
{
    PlayerEnvoy *other = [PlayerEnvoy envoyFromPeerID:message.from];
    if (!other || !other.playerName || other.playerName.length == 0)
    {
        if (!self.stash)
        {
            NSMutableArray *stash = [[NSMutableArray alloc] initWithCapacity:kPartisansMaxPlayers - 1];
            self.stash = stash;
            [stash release];
        }
        [self.stash addObject:message];
        return;
    }
    [self addPlayerToGame:other responseKey:message.responseKey];
}


- (void)addPlayerToGame:(PlayerEnvoy *)playerEnvoy responseKey:(NSString *)responseKey
{
    BOOL proceed = NO;
    GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
    if ([SystemMessage isHost])
    {
        // We are hosting a game.
        if (gameEnvoy.players.count < kPartisansMaxPlayers && !gameEnvoy.startDate)
        {
            // The game has room and hasn't yet started.
            // So, let the other player join, and send the game object back!
            proceed = YES;
        }
    }
    if (proceed)
    {
        // Make sure this player isn't already in the game.
        if ([gameEnvoy isPlayerInGame:playerEnvoy])
        {
            proceed = NO;
        }
    }
    
    if (!proceed)
    {
        return;
    }
    
    // Add this player to the game.
    [gameEnvoy addPlayer:playerEnvoy];
    UpdateGameOperation *op = [[UpdateGameOperation alloc] initWithEnvoy:gameEnvoy];
//    AddGamePlayerOperation *op = [[AddGamePlayerOperation alloc] initWithEnvoy:playerEnvoy];
    [op setCompletionBlock:^(void) {
        dispatch_async(dispatch_get_main_queue(), ^(void)
       {
           [[NSNotificationCenter defaultCenter] postNotificationName:kPartisansNotificationGameChanged object:nil];
       });
        // Then, once we've saved, send the game envoy to all players. All players need to know!
        JSKCommandParcel *parcel = [[JSKCommandParcel alloc] initWithType:JSKCommandParcelTypeResponse
                                                                       to:nil
                                                                     from:self.playerEnvoy.peerID
                                                                   object:gameEnvoy
                                                              responseKey:responseKey];
        [self.netHost broadcastCommandParcel:parcel];
//        [SystemMessage sendParcelToPlayers:parcel];
        [parcel release];
    }];
    NSOperationQueue *queue = [SystemMessage mainQueue];
    [queue addOperation:op];
    [op release];
}


- (void)handleLeaveGameMessage:(JSKCommandMessage *)message
{
    PlayerEnvoy *other = [PlayerEnvoy envoyFromPeerID:message.from];
    if (!other)
    {
        return;
    }
    // Make sure this player is in the game.
    GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
    if (![gameEnvoy isPlayerInGame:other])
    {
        return;
    }
    
    // Remove this player from the game.
    RemoveGamePlayerOperation *op = [[RemoveGamePlayerOperation alloc] initWithEnvoy:other];
    [op setCompletionBlock:^(void) {
        JSKCommandParcel *gameParcel = [[JSKCommandParcel alloc] initWithType:JSKCommandParcelTypeUpdate to:nil from:self.playerEnvoy.peerID object:gameEnvoy];
        [SystemMessage sendParcelToPlayers:gameParcel];
        [gameParcel release];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kPartisansNotificationGameChanged object:nil];
        });
    }];
    NSOperationQueue *queue = [SystemMessage mainQueue];
    [queue addOperation:op];
    [op release];
}


#pragma mark - Player

- (BOOL)isReadyToJoinGame
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

- (void)askToJoinGameDelayed:(NSString *)toPeerID
{
    [self performSelector:@selector(askToJoinGame:) withObject:toPeerID afterDelay:2.0];
}

- (void)askToJoinGame:(NSString *)toPeerID
{
    if (!self.isLookingForGame)
    {
        return;
    }
    if ([SystemMessage isHost])
    {
        return;
    }
    
    JSKCommandMessage *msg = [[JSKCommandMessage alloc] initWithType:JSKCommandMessageTypeJoinGame to:toPeerID from:[SystemMessage playerEnvoy].peerID];
    [SystemMessage sendCommandMessage:msg shouldAwaitResponse:YES];
    [msg release];
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
    
    self.isLookingForGame = NO;
    
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
                [self setGameEnvoy:updatedEnvoy];
                
                // Also, post a notification that we joined the game.
                [[NSNotificationCenter defaultCenter] postNotificationName:kPartisansNotificationJoinedGame object:updatedEnvoy];
            }
        });
    }];
    NSOperationQueue *queue = [SystemMessage mainQueue];
    [queue addOperation:op];
    [op release];
}


#pragma mark - Player / Host

// The will check the local data and ask for new data as needed.
- (void)processDigest:(NSDictionary *)digest
{
    BOOL wasNewDataRequested = NO;
    // The digest is a dictionary of Player.modifiedDate values, keyed on peerID.
    PlayerEnvoy *playerEnvoy = [SystemMessage playerEnvoy];
    for (NSString *otherID in digest.allKeys)
    {
        BOOL shouldAskForData = NO;
        NSDate *otherDate = [digest valueForKey:otherID];
        if (otherDate)
        {
            PlayerEnvoy *otherEnvoy = [PlayerEnvoy envoyFromPeerID:otherID];
            if (otherEnvoy)
            {
                if ([SystemMessage secondsBetweenDates:otherEnvoy.modifiedDate toDate:otherDate] > 0)
                {
                    shouldAskForData = YES;
                }
            }
            else
            {
                shouldAskForData = YES;
            }
        }
        if (shouldAskForData)
        {
            // If we are a Host, then the dictionary will contain one row, and we'll send the message to that Player.
            // If we are a Player, the "to" field will not necessarily be the Host's address. But we'll be sending the message to the Host.
            // Note the use of the "to" field here, to indicate that we're interested in that player's info, not (necessarily) the recipient's.
            JSKCommandMessage *message = [[JSKCommandMessage alloc] initWithType:JSKCommandMessageTypeGetInfo to:otherID from:playerEnvoy.peerID];
            [SystemMessage sendCommandMessage:message shouldAwaitResponse:YES];
            [message release];
            wasNewDataRequested = YES;
        }
    }
    if (!wasNewDataRequested)
    {
        if ([SystemMessage isHost])
        {
            NSString *otherID = [digest.allKeys objectAtIndex:0];
            [self sendDigestTo:otherID];
        }
        else
        {
            if (self.isLookingForGame)
            {
                if ([self isReadyToJoinGame])
                {
                    [self askToJoinGameDelayed:self.netPlayer.hostPeerID];
                }
            }
        }
    }
}

#pragma mark - Peer Controller stuff


- (void)handleResponse:(JSKCommandParcel *)commandParcel inResponseToParcel:(JSKCommandParcel *)inResponseToParcel
{
    if ([commandParcel.object isKindOfClass:[PlayerEnvoy class]])
    {
        [self handleGetInfoResponse:commandParcel];
    }
}


- (void)handleModifiedDateResponse:(JSKCommandParcel *)response
{
    if (!response.object)
    {
        return;
    }
    if (![response.object isKindOfClass:[NSDate class]])
    {
        return;
    }
    
    NSDate *modifiedDate = (NSDate *)response.object;
    
    // A "regarding" attribute in the response would help narrow the focus of this operation.
    // (For instance, an ID that keys to an entity, or particular attribute on an entity)
    // Like, an ID would mean "the modified date of the picture on the player"
    // Stored in a custom object perhaps, Operation class or something.
    
    // For now assume the modified date of the peer, which is a player.
    // We use this date to determine whether to ask for player info.
    
    PlayerEnvoy *other = [PlayerEnvoy envoyFromPeerID:response.from];
    if (!other)
    {
        return;
    }
    if (!modifiedDate || !other.modifiedDate)
    {
        return;
    }
    if ([SystemMessage secondsBetweenDates:other.modifiedDate toDate:modifiedDate] > 0)
    {
        // Apparently new information is available! Let's ask for it.
        JSKCommandMessage *msg = [[JSKCommandMessage alloc] initWithType:JSKCommandMessageTypeGetInfo to:response.from from:self.playerEnvoy.peerID];
        [self.netHost sendCommandMessage:msg shouldAwaitResponse:YES];
        [msg release];
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
        
        // We may already know about this player.
        PlayerEnvoy *localOther = [PlayerEnvoy envoyFromPeerID:other.peerID];
        if (localOther)
        {
            UpdatePlayerOperation *op = [[UpdatePlayerOperation alloc] initWithEnvoy:other];
            [op setCompletionBlock:^(void){
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Send them our info back, to be polite.
                    JSKCommandParcel *response = [[JSKCommandParcel alloc] initWithType:JSKCommandParcelTypeResponse
                                                                                     to:parcel.from
                                                                                   from:self.playerEnvoy.peerID
                                                                                 object:self.playerEnvoy
                                                                            responseKey:parcel.responseKey];
                    [SystemMessage sendCommandParcel:response shouldAwaitResponse:NO];
                    [response release];
                    if (self.isLookingForGame)
                    {
                        [self askToJoinGameDelayed:other.peerID];
                    }
                    else
                    {
                        [self handleJoinGameStash:other.peerID];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:JSKNotificationPeerUpdated object:other.peerID];
                });
            }];
            NSOperationQueue *queue = [SystemMessage mainQueue];
            [queue addOperation:op];
            [op release];
            return;
        }
        
        CreatePlayerOperation *op = [[CreatePlayerOperation alloc] initWithEnvoy:other];
        [op setCompletionBlock:^(void){
            dispatch_async(dispatch_get_main_queue(), ^{
                // A new player, so let's send them our info back, to be polite.
                JSKCommandParcel *response = [[JSKCommandParcel alloc] initWithType:JSKCommandParcelTypeResponse
                                                                                 to:parcel.from
                                                                               from:self.playerEnvoy.peerID
                                                                             object:self.playerEnvoy
                                                                        responseKey:parcel.responseKey];
                [SystemMessage sendCommandParcel:response shouldAwaitResponse:NO];
                [response release];
                if (self.isLookingForGame)
                {
                    [self askToJoinGameDelayed:other.peerID];
                }
                else
                {
                    [self handleJoinGameStash:other.peerID];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:JSKNotificationPeerCreated object:other.peerID];
            });
        }];
        NSOperationQueue *queue = [SystemMessage mainQueue];
        [queue addOperation:op];
        [op release];
    }
    
    return;
}

- (void)handleGetInfoResponse:(JSKCommandParcel *)response
{
    NSObject *object = response.object;
    if ([object isKindOfClass:[PlayerEnvoy class]])
    {
        PlayerEnvoy *other = (PlayerEnvoy *)object;
        other.isNative = NO;
        other.isDefault = NO;
        
        // We may already know about this player.
        PlayerEnvoy *localOther = [PlayerEnvoy envoyFromPeerID:other.peerID];
        if (localOther)
        {
            UpdatePlayerOperation *op = [[UpdatePlayerOperation alloc] initWithEnvoy:other];
            [op setCompletionBlock:^(void){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.isLookingForGame)
                    {
                        [self askToJoinGameDelayed:other.peerID];
                    }
                    else
                    {
                        [self handleJoinGameStash:other.peerID];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:JSKNotificationPeerUpdated object:other.peerID];
                });
            }];
            NSOperationQueue *queue = [SystemMessage mainQueue];
            [queue addOperation:op];
            [op release];
            return;
        }
        
        CreatePlayerOperation *op = [[CreatePlayerOperation alloc] initWithEnvoy:other];
        [op setCompletionBlock:^(void){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.isLookingForGame)
                {
                    [self askToJoinGameDelayed:other.peerID];
                }
                else
                {
                    [self handleJoinGameStash:other.peerID];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:JSKNotificationPeerCreated object:other.peerID];
            });
        }];
        NSOperationQueue *queue = [SystemMessage mainQueue];
        [queue addOperation:op];
        [op release];
    }
    
    return;
}


- (void)handleJoinGameStash:(NSString *)fromPeerID
{
    if (![SystemMessage isHost])
    {
        return;
    }
//    BOOL shouldAddPlayer = YES;
    for (JSKCommandMessage *stashedMsg in self.stash)
    {
        if (stashedMsg.commandMessageType == JSKCommandMessageTypeJoinGame)
        {
            if ([stashedMsg.from isEqualToString:fromPeerID])
            {
                [self.stash removeObject:stashedMsg];
                [self handleJoinGameMessage:stashedMsg];
//                shouldAddPlayer = NO;
                break;
            }
        }
    }
//    if (shouldAddPlayer)
//    {
//        [self addPlayerToGame:[PlayerEnvoy envoyFromPeerID:fromPeerID] responseKey:nil];
//    }
}


#pragma mark - NetHost delegate

- (NSString *)netHostPeerID:(NetHost *)netHost
{
    return self.playerEnvoy.peerID;
}

- (void)netHost:(NetHost *)netHost receivedCommandParcel:(JSKCommandParcel *)commandParcel
{
    switch (commandParcel.commandParcelType) {
        case JSKCommandParcelTypeDigest:
            // A player will not send this.
            break;
            
        case JSKCommandParcelTypeModifiedDate:
        {
            NSString *otherID = commandParcel.from;
            NSDate *otherDate = (NSDate *)commandParcel.object;
            [self processDigest:[NSDictionary dictionaryWithObject:otherDate forKey:otherID]];
            break;
        }
            
        case JSKCommandParcelTypeResponse:
            break;
            
        case JSKCommandParcelTypeUpdate:
            if ([commandParcel.object isKindOfClass:[PlayerEnvoy class]])
            {
                [self handlePlayerUpdate:commandParcel];
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
    if ([inResponseTo isKindOfClass:[JSKCommandMessage class]])
    {
        JSKCommandMessage *msg = (JSKCommandMessage *)inResponseTo;
        [self handlePlayerResponse:commandParcel inResponseTo:msg];
    }
    else if ([inResponseTo isKindOfClass:[JSKCommandParcel class]])
    {
        JSKCommandParcel *parcel = (JSKCommandParcel *)inResponseTo;
        [self handleResponse:commandParcel inResponseToParcel:parcel];
    }
}


- (void)netHost:(NetHost *)netHost receivedCommandMessage:(JSKCommandMessage *)commandMessage
{
    NSString *peerID = commandMessage.from;
    PlayerEnvoy *other = [PlayerEnvoy envoyFromPeerID:peerID];
    if (!other)
    {
        // Unidentified or unmatched player.
        debugLog(@"Message from unknown peer %@", commandMessage);
        return;
    }
    
    if (commandMessage.commandMessageType == JSKCommandMessageTypeJoinGame)
    {
        [self handleJoinGameMessage:commandMessage];
        return;
    }
    
//    if (!other)
//    {
//        // Unidentified or unmatched player.
//        // This is actually ok if the command is an Identification.
//        // An Identification message contains the sender's ID.
//        // This is the equivalent of telling someone your name.
//        // Once I save that player's ID, and she saves mine, we can communicate.
//        if (commandMessage.commandMessageType == JSKCommandMessageTypeIdentification)
//        {
//            [self handleIdentification:commandMessage];
//        }
//        return;
//    }

    // The "to" field tells us which player the sender is interested in.
    PlayerEnvoy *playerEnvoy = [PlayerEnvoy envoyFromPeerID:commandMessage.to];
//    PlayerEnvoy *playerEnvoy = self.playerEnvoy;
    JSKCommandMessageType messageType = commandMessage.commandMessageType;
//    JSKCommandParcelType parcelType = JSKCommandParcelTypeUnknown;
    NSObject <NSCoding> *responseObject = nil;
    
    switch (messageType)
    {
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
        case JSKCommandMessageTypeIdentification:
        {
            // If not caught above then we already know about this player.
            // Let's get their data.
            JSKCommandMessage *msg = [[JSKCommandMessage alloc] initWithType:JSKCommandMessageTypeGetInfo to:commandMessage.from from:self.playerEnvoy.peerID];
            [self.netHost sendCommandMessage:msg shouldAwaitResponse:YES];
            [msg release];
            break;
        }
        case JSKCommandMessageTypeLeaveGame:
            [self handleLeaveGameMessage:commandMessage];
            break;
        default:
            break;
    }
    
    if (responseObject)
    {
        JSKCommandParcel *response = [[JSKCommandParcel alloc] initWithType:JSKCommandParcelTypeResponse
                                                                         to:peerID
                                                                       from:playerEnvoy.peerID
                                                                     object:responseObject
                                                                responseKey:commandMessage.responseKey];
        [netHost sendCommandParcel:response];
        [response release];
    }
}

- (void)netHost:(NetHost *)netHost terminated:(NSString *)reason
{
    debugLog(@"NetHost terminated: %@", reason);
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
        [response release];
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
        
        UpdatePlayerOperation *op = [[UpdatePlayerOperation alloc] initWithEnvoy:other];
        [op setCompletionBlock:^(void){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.isLookingForGame)
                {
                    if ([self isReadyToJoinGame])
                    {
                        [self askToJoinGameDelayed:other.peerID];
                    }
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:JSKNotificationPeerUpdated object:other.peerID];
            });
        }];
        NSOperationQueue *queue = [SystemMessage mainQueue];
        [queue addOperation:op];
        [op release];
        return;
    }
    
    // Save the Game data locally.
    if ([object isKindOfClass:[GameEnvoy class]])
    {
        // Let's make sure the copy we're getting is newer than the one we have currently.
        GameEnvoy *currentGame = self.gameEnvoy;
        GameEnvoy *updatedGame = (GameEnvoy *)commandParcel.object;
        if (currentGame.modifiedDate && updatedGame.modifiedDate)
        {
            NSInteger delta = [SystemMessage secondsBetweenDates:currentGame.modifiedDate toDate:updatedGame.modifiedDate];
            if (delta <= 0)
            {
                return;
            }
        }
        
        UpdateGameOperation *op = [[UpdateGameOperation alloc] initWithEnvoy:updatedGame];
        [op setCompletionBlock:^(void){
            [[NSNotificationCenter defaultCenter] postNotificationName:kPartisansNotificationGameChanged object:nil];
        }];
        NSOperationQueue *queue = [SystemMessage mainQueue];
        [queue addOperation:op];
        [op release];
        return;
    }
}

- (void)netPlayer:(NetPlayer *)netPlayer receivedCommandParcel:(JSKCommandParcel *)commandParcel respondingTo:(NSObject<NSCoding> *)inResponseTo
{
    if ([inResponseTo isKindOfClass:[JSKCommandMessage class]])
    {
        JSKCommandMessage *message = (JSKCommandMessage *)inResponseTo;
        if (message.commandMessageType == JSKCommandMessageTypeJoinGame)
        {
            [self handleJoinGameResponse:commandParcel];
            return;
        }
    }
    [self netPlayer:netPlayer receivedCommandParcel:commandParcel];
}

- (void)netPlayer:(NetPlayer *)netPlayer terminated:(NSString *)reason
{
    debugLog(@"NetPlayer terminated: %@", reason);
}

- (void)netPlayerDidResolveAddress:(NetPlayer *)netPlayer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kPartisansNotificationConnectedToHost object:nil];
    });
}

#pragma mark - Class methods

+ (BOOL)connectToService:(NSNetService *)service
{
    SystemMessage *sharedInstance = [self sharedInstance];
    if (sharedInstance.netPlayer)
    {
        [sharedInstance.netPlayer stop];
        [sharedInstance.netPlayer setDelegate:nil];
        sharedInstance.netPlayer = nil;
    }
    NetPlayer *netPlayer = [[NetPlayer alloc] initWithNetService:service];
    [netPlayer setDelegate:sharedInstance];
    [sharedInstance setNetPlayer:netPlayer];
    [netPlayer release];
    return [sharedInstance.netPlayer start];
}

+ (void)askToJoinGame
{
    [self sendToHost:JSKCommandMessageTypeJoinGame shouldAwaitResponse:YES];
//    [self broadcastCommandMessage:JSKCommandMessageTypeJoinGame];
}

+ (BOOL)isHost
{
    GameEnvoy *gameEnvoy = [self gameEnvoy];
    if (!gameEnvoy)
    {
        return NO;
    }
    PlayerEnvoy *playerEnvoy = [self playerEnvoy];
    PlayerEnvoy *host = [gameEnvoy host];
    if ([playerEnvoy.intramuralID isEqualToString:host.intramuralID])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL)isPlayerOnline
{
    SystemMessage *sharedInstance = [self sharedInstance];
    if ([self isHost])
    {
        NetHost *netHost = sharedInstance.netHost;
        if (!netHost)
        {
            NetHost *netHost = [[NetHost alloc] init];
            [netHost setDelegate:sharedInstance];
            [sharedInstance setNetHost:netHost];
            [netHost release];
        }
        return netHost.hasStarted;
    }
    else
    {
        NetPlayer *netPlayer = sharedInstance.netPlayer;
        if (!netPlayer)
        {
            NetPlayer *netPlayer = [[NetPlayer alloc] init];
            [netPlayer setDelegate:sharedInstance];
            [sharedInstance setNetPlayer:netPlayer];
            [netPlayer release];
        }
        return netPlayer.hasStarted;
    }
}

+ (void)putPlayerOffline
{
    SystemMessage *sharedInstance = [self sharedInstance];
    if ([self isHost])
    {
        if (sharedInstance.netHost.hasStarted)
        {
            [sharedInstance.netHost stop];
        }
    }
    else
    {
        if (sharedInstance.netPlayer.hasStarted)
        {
            [sharedInstance.netPlayer stop];
        }
    }
}

+ (void)putPlayerOnline
{
    SystemMessage *sharedInstance = [self sharedInstance];
    if ([self isHost])
    {
        if (!sharedInstance.netHost.hasStarted)
        {
            [sharedInstance.netHost start];
        }
    }
    else
    {
        if (!sharedInstance.netPlayer.hasStarted)
        {
            [sharedInstance.netPlayer start];
        }
    }
}


+ (void)broadcastCommandMessage:(JSKCommandMessageType)commandMessageType
{
    if (![self isPlayerOnline])
    {
        return;
    }
    SystemMessage *sharedInstance = [self sharedInstance];
    NetHost *netHost = sharedInstance.netHost;
    
    [netHost broadcastCommandMessageType:commandMessageType];
}


+ (void)sendCommandMessage:(JSKCommandMessage *)commandMessage
{
    if (![self isPlayerOnline])
    {
        return;
    }
    if ([self isHost])
    {
        [[self sharedInstance].netHost sendCommandMessage:commandMessage];
    }
    else
    {
        [[self sharedInstance].netPlayer sendCommandMessage:commandMessage];
    }
}


+ (void)sendCommandMessage:(JSKCommandMessage *)commandMessage shouldAwaitResponse:(BOOL)shouldAwaitResponse
{
    if (![self isPlayerOnline])
    {
        return;
    }
    if ([self isHost])
    {
        [[self sharedInstance].netHost sendCommandMessage:commandMessage shouldAwaitResponse:shouldAwaitResponse];
    }
    else
    {
        [[self sharedInstance].netPlayer sendCommandMessage:commandMessage shouldAwaitResponse:shouldAwaitResponse];
    }
}

+ (void)sendCommandParcel:(JSKCommandParcel *)parcel shouldAwaitResponse:(BOOL)shouldAwaitResponse
{
    if (![self isPlayerOnline])
    {
        return;
    }
    if ([self isHost])
    {
        [[self sharedInstance].netHost sendCommandParcel:parcel shouldAwaitResponse:shouldAwaitResponse];
    }
    else
    {
        [[self sharedInstance].netPlayer sendCommandParcel:parcel shouldAwaitResponse:shouldAwaitResponse];
    }
}

+ (void)sendToHost:(JSKCommandMessageType)commandMessageType shouldAwaitResponse:(BOOL)shouldAwaitResponse
{
    if (![self isPlayerOnline])
    {
        return;
    }
    NSString *hostID = nil;
    PlayerEnvoy *host = [self sharedInstance].gameEnvoy.host;
    if (host)
    {
        hostID = host.peerID;
    }
    JSKCommandMessage *msg = [[JSKCommandMessage alloc] initWithType:commandMessageType to:hostID from:[self playerEnvoy].peerID];
    NetPlayer *netPlayer = [self sharedInstance].netPlayer;
    [netPlayer sendCommandMessage:msg shouldAwaitResponse:shouldAwaitResponse];
    [msg release];
}

+ (void)sendParcelToPlayers:(JSKCommandParcel *)parcel
{
    if (![self isPlayerOnline])
    {
        return;
    }
    if (!parcel.from)
    {
        [parcel setFrom:[self playerEnvoy].peerID];
    }
    NetHost *netHost = [self sharedInstance].netHost;
    GameEnvoy *gameEnvoy = [self gameEnvoy];
    for (PlayerEnvoy *playerEnvoy in gameEnvoy.players)
    {
        // Don't send to ourselves.
        if (![playerEnvoy.peerID isEqualToString:[self playerEnvoy].peerID])
        {
            [parcel setTo:playerEnvoy.peerID];
            [netHost sendCommandParcel:parcel];
        }
    }
}


+ (SystemMessage *)sharedInstance
{
    SystemMessage *singleton = (SystemMessage *)[super sharedInstance];
    return singleton;
}

+ (PlayerEnvoy *)playerEnvoy
{
    return [self sharedInstance].playerEnvoy;
}

+ (GameEnvoy *)gameEnvoy
{
    GameEnvoy *gameEnvoy = [self sharedInstance].gameEnvoy;
    if (gameEnvoy)
    {
        return gameEnvoy;
    }
    // Are we hosting a game?
    PlayerEnvoy *playerEnvoy = [self sharedInstance].playerEnvoy;
    gameEnvoy = [GameEnvoy envoyFromHost:playerEnvoy];
    if (gameEnvoy)
    {
        [[self sharedInstance] setGameEnvoy:gameEnvoy];
        return gameEnvoy;
    }
    // Are we playing a game?
    gameEnvoy = [GameEnvoy envoyFromPlayer:playerEnvoy];
    if (gameEnvoy)
    {
        [[self sharedInstance] setGameEnvoy:gameEnvoy];
        return gameEnvoy;
    }
    
    return nil;
}

+ (BOOL)isSameDay:(NSDate *)firstDate as:(NSDate *)secondDate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents *firstDateParts = [gregorian components:unitFlags fromDate:firstDate];
    NSDateComponents *secondDateParts = [gregorian components:unitFlags fromDate:secondDate];
    [gregorian release];
    
    if ([firstDateParts day] == [secondDateParts day])
    {
        if ([firstDateParts month] == [secondDateParts month])
        {
            if ([firstDateParts year] == [secondDateParts year])
            {
                return YES;
            }
        }
    }
    
    return NO;
}


+ (NSInteger)secondsBetweenDates:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSUInteger unitFlags = NSSecondCalendarUnit;
    
    NSDateComponents *components = [gregorian components:unitFlags
                                                fromDate:fromDate
                                                  toDate:toDate
                                                 options:0];
    [gregorian release];
    
    return [components second];
}


+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSizeWithSameAspectRatio:(CGSize)targetSize
{
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor; // scale to fit height
        }
        else {
            scaleFactor = heightFactor; // scale to fit width
        }
        
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor) {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef bitmap;
    
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    } else {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    }
    
    // In the right or left cases, we need to switch scaledWidth and scaledHeight,
    // and also the thumbnail point
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
        
        CGContextRotateCTM (bitmap, M_PI_2); // + 90 degrees
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationRight) {
        thumbnailPoint = CGPointMake(thumbnailPoint.y, thumbnailPoint.x);
        CGFloat oldScaledWidth = scaledWidth;
        scaledWidth = scaledHeight;
        scaledHeight = oldScaledWidth;
        
        CGContextRotateCTM (bitmap, -M_PI_2); // - 90 degrees
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (sourceImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, -M_PI); // - 180 degrees
    }
    
    CGContextDrawImage(bitmap, CGRectMake(thumbnailPoint.x, thumbnailPoint.y, scaledWidth, scaledHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage; 
}

@end
