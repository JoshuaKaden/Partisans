//
//  NetworkManager.m
//  Partisans
//
//  Created by Joshua Kaden on 8/3/15.
//  Copyright © 2015 Chadford Software. All rights reserved.
//

#import "NetworkManager.h"

#import "GameEnvoy.h"
#import "NetHost.h"
#import "NetHostHandler.h"
#import "NetPlayer.h"
#import "NetPlayerHandler.h"
#import "PlayerEnvoy.h"
#import "SystemMessage.h"

@interface NetworkManager ()
@property (nonatomic, strong) NetHost *netHost;
@property (nonatomic, strong) NetHostHandler *netHostHandler;
@property (nonatomic, strong) NetPlayer *netPlayer;
@property (nonatomic, strong) NetPlayerHandler *netPlayerHandler;
@property (nonatomic, readonly) PlayerEnvoy *playerEnvoy;
@end

@implementation NetworkManager

+ (NetworkManager *)sharedInstance
{
    static dispatch_once_t pred;
    static NetworkManager *sharedInstance = nil;
    dispatch_once(&pred, ^{ sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}

- (void)dealloc
{
    [_netHost setDelegate:nil];
    [_netPlayer setDelegate:nil];
}

+ (BOOL)isPlayerOnline
{
    NetworkManager *sharedInstance = [self sharedInstance];
    if ([SystemMessage isHost]) {
        NetHost *netHost = sharedInstance.netHost;
        if (!netHost) {
            NetHost *netHost = [[NetHost alloc] init];
            netHost.serviceName = [SystemMessage serviceName];
            sharedInstance.netHostHandler = [NetHostHandler new];
            [netHost setDelegate:sharedInstance.netHostHandler];
            [sharedInstance setNetHost:netHost];
        }
        return netHost.hasStarted;
    } else {
        NetPlayer *netPlayer = sharedInstance.netPlayer;
        if (!netPlayer) {
            NetPlayer *netPlayer = [[NetPlayer alloc] init];
            sharedInstance.netPlayerHandler = [NetPlayerHandler new];
            [netPlayer setDelegate:sharedInstance.netPlayerHandler];
            [sharedInstance setNetPlayer:netPlayer];
        }
        return netPlayer.hasStarted;
    }
}

+ (void)putPlayerOnline
{
    if ([self isPlayerOnline]) {
        return;
    }
    
    NetworkManager *sharedInstance = [self sharedInstance];
    if ([SystemMessage isHost]) {
        if (!sharedInstance.netHost.hasStarted) {
            [sharedInstance.netHost start];
        }
    } else {
        if (!sharedInstance.netPlayer.hasStarted) {
            if (![sharedInstance.netPlayer start]) {
                [SystemMessage browseServers];
            }
        }
    }
}

+ (void)putPlayerOffline
{
    NetworkManager *sharedInstance = [self sharedInstance];
    if ([SystemMessage isHost]) {
        if (sharedInstance.netHost.hasStarted) {
            [sharedInstance.netHost stop];
        }
        sharedInstance.netHost.delegate = nil;
        sharedInstance.netHost = nil;
    } else {
        if (sharedInstance.netPlayer.hasStarted) {
            [sharedInstance.netPlayer stop];
        }
        sharedInstance.netPlayer.delegate = nil;
        sharedInstance.netPlayer = nil;
    }
}

+ (void)sendCommandMessage:(JSKCommandMessage *)commandMessage shouldAwaitResponse:(BOOL)shouldAwaitResponse
{
    if (![self isPlayerOnline]) {
        return;
    }
    
    if ([SystemMessage isHost]) {
        [[self sharedInstance].netHost sendCommandMessage:commandMessage shouldAwaitResponse:shouldAwaitResponse];
    } else {
        [[self sharedInstance].netPlayer sendCommandMessage:commandMessage shouldAwaitResponse:shouldAwaitResponse];
    }
}

+ (void)sendCommandParcel:(JSKCommandParcel *)parcel shouldAwaitResponse:(BOOL)shouldAwaitResponse
{
    if (![self isPlayerOnline]) {
        return;
    }
    
    if ([SystemMessage isHost]) {
        [[self sharedInstance].netHost sendCommandParcel:parcel shouldAwaitResponse:shouldAwaitResponse];
    } else {
        [[self sharedInstance].netPlayer sendCommandParcel:parcel shouldAwaitResponse:shouldAwaitResponse];
    }
}

+ (void)sendToHost:(JSKCommandMessageType)commandMessageType shouldAwaitResponse:(BOOL)shouldAwaitResponse
{
    if (![self isPlayerOnline]) {
        return;
    }
    
    PlayerEnvoy *host = [SystemMessage gameEnvoy].host;
    if (!host) {
        return;
    }
    
    NSString *hostID = host.peerID;
    JSKCommandMessage *msg = [[JSKCommandMessage alloc] initWithType:commandMessageType to:hostID from:[SystemMessage playerEnvoy].peerID];
    NetPlayer *netPlayer = [self sharedInstance].netPlayer;
    [netPlayer sendCommandMessage:msg shouldAwaitResponse:shouldAwaitResponse];
}

+ (void)sendParcelToPlayers:(JSKCommandParcel *)parcel
{
    if (![self isPlayerOnline]) {
        return;
    }
    
    if (!parcel.from) {
        [parcel setFrom:[SystemMessage playerEnvoy].peerID];
    }
    NetHost *netHost = [self sharedInstance].netHost;
    GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
    for (PlayerEnvoy *playerEnvoy in gameEnvoy.players) {
        // Don't send to ourselves.
        if (![playerEnvoy.peerID isEqualToString:[SystemMessage playerEnvoy].peerID]) {
            [parcel setTo:playerEnvoy.peerID];
            [netHost sendCommandParcel:parcel];
        }
    }
}

+ (void)setupNetPlayerWithService:(NSNetService *)service
{
    [[self sharedInstance] setupNetPlayerWithService:service];
}

- (void)setupNetPlayerWithService:(NSNetService *)service
{
    if (self.netPlayer) {
        [self.netPlayer stop];
        [self.netPlayer setDelegate:nil];
        self.netPlayer = nil;
    }
    NetPlayer *netPlayer = [[NetPlayer alloc] initWithNetService:service];
    self.netPlayerHandler = [NetPlayerHandler new];
    [netPlayer setDelegate:self.netPlayerHandler];
    [self setNetPlayer:netPlayer];
    [self.netPlayer start];
}

+ (void)askToJoinGame
{
    [self askToJoinGameHostedBy:nil];
}

+ (void)askToJoinGameHostedBy:(NSString *)hostID
{
    if (!hostID) {
        hostID = [self sharedInstance].netPlayer.hostPeerID;
    }
    [[self sharedInstance] askToJoinGameDelayedHostedBy:hostID];
}

- (void)askToJoinGameDelayedHostedBy:(NSString *)hostID
{
    [self performSelector:@selector(askToJoinGame:) withObject:hostID afterDelay:2.0];
}

- (void)askToJoinGame:(NSString *)toPeerID
{
    if (![SystemMessage sharedInstance].isLookingForGame) {
        return;
    }
    if ([SystemMessage isHost]) {
        return;
    }
    
    JSKCommandMessage *msg = [[JSKCommandMessage alloc] initWithType:JSKCommandMessageTypeJoinGame to:toPeerID from:[SystemMessage playerEnvoy].peerID];
    [NetworkManager sendCommandMessage:msg shouldAwaitResponse:YES];
}

@end
