//
//  GameJoiner.m
//  Partisans
//
//  Created by Joshua Kaden on 5/17/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "GameJoiner.h"

#import "GameEnvoy.h"
#import "JSKCommandMessage.h"
#import "PlayerEnvoy.h"
#import "SystemMessage.h"


@interface GameJoiner ()

@property (readwrite) BOOL isScanning;

- (void)peerWasUpdated:(NSNotification *)notification;
- (void)gameWasJoined:(NSNotification *)notification;

@end


@implementation GameJoiner

@synthesize delegate = m_delegate;
@synthesize isScanning = m_isScanning;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


- (void)raiseStatusMessage:(NSString *)message
{
    if ([self.delegate respondsToSelector:@selector(gameJoiner:handleStatusMessage:)])
    {
        [self.delegate gameJoiner:self handleStatusMessage:message];
    }
}

- (void)startScanning
{
    if (![SystemMessage isPlayerOnline])
    {
        [SystemMessage putPlayerOnline];
    }
    [SystemMessage broadcastCommandMessage:JSKCommandMessageTypeJoinGame];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peerWasUpdated:) name:JSKNotificationPeerUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameWasJoined:) name:kPartisansNotificationJoinedGame object:nil];
    
    NSString *message = NSLocalizedString(@"Scanning for a game...", @"Scanning for a game...  -  status message");
    [self raiseStatusMessage:message];
}

- (void)stopScanning
{
    [SystemMessage putPlayerOffline];
    
    NSString *message = NSLocalizedString(@"The scanner is off.", @"The scanner is off.  -  status message");
    [self raiseStatusMessage:message];
}

- (void)peerWasUpdated:(NSNotification *)notification
{
    // The idea here is that once we've exchanged pleasantries with a peer,
    // we ask to join a game if that peer happens to be hosting.
    NSString *peerID = (NSString *)notification.object;
    PlayerEnvoy *other = [PlayerEnvoy envoyFromPeerID:peerID];
    // Paranoia check
    if (!other)
    {
        return;
    }
    JSKCommandMessage *msg = [[JSKCommandMessage alloc] initWithType:JSKCommandMessageTypeJoinGame to:peerID from:[SystemMessage playerEnvoy].peerID];
    [SystemMessage sendCommandMessage:msg];
    [msg release];
}

- (void)gameWasJoined:(NSNotification *)notification
{
    [self.delegate gameJoinerDidFinish:self];
}

@end
