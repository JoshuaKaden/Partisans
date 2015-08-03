//
//  GameJoiner.m
//  Partisans
//
//  Created by Joshua Kaden on 5/17/13.
//
//  Copyright (c) 2013, Joshua Kaden
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
//  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "GameJoiner.h"

#import "GameEnvoy.h"
#import "JSKCommandMessage.h"
#import "PlayerEnvoy.h"
#import "SystemMessage.h"


@interface GameJoiner ()

@property (readwrite) BOOL isScanning;
@property (readwrite) BOOL hasJoinedGame;
@property (nonatomic, strong) NSTimer *timer;

- (void)peerWasUpdated:(NSNotification *)notification;
- (void)peerWasCreated:(NSNotification *)notification;
- (void)gameWasJoined:(NSNotification *)notification;
- (void)connectedToHost:(NSNotification *)notification;
- (void)timerFired:(id)sender;

@end


@implementation GameJoiner

@synthesize delegate = m_delegate;
@synthesize isScanning = m_isScanning;
@synthesize hasJoinedGame = m_hasJoinedGame;
@synthesize timer = m_timer;
@synthesize gameCode = m_gameCode;


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.timer invalidate];
    
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
//    [SystemMessage sharedInstance].isLookingForGame = YES;
//    
//    if (![SystemMessage isPlayerOnline])
//    {
//        [SystemMessage putPlayerOnline];
//    }
//    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
////    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peerWasUpdated:) name:JSKNotificationPeerUpdated object:nil];
////    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peerWasCreated:) name:JSKNotificationPeerCreated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameWasJoined:) name:kPartisansNotificationJoinedGame object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectedToHost:) name:kPartisansNotificationConnectedToHost object:nil];
    
    NSString *message = NSLocalizedString(@"Scanning for a game...", @"Scanning for a game...  -  status message");
    [self raiseStatusMessage:message];
    
    [SystemMessage sharedInstance].isLookingForGame = YES;
    [SystemMessage sharedInstance].gameCode = self.gameCode;
    [SystemMessage browseServers];
    
    if (!self.timer)
    {
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
        self.timer = timer;
    }
}

- (void)stopScanning
{
    [SystemMessage stopBrowsingServers];
    [SystemMessage sharedInstance].isLookingForGame = NO;
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [SystemMessage putPlayerOffline];
    
    NSString *message = NSLocalizedString(@"The scanner is off.", @"The scanner is off.  -  status message");
    [self raiseStatusMessage:message];
}

- (void)peerWasUpdated:(NSNotification *)notification
{
//    if (self.hasJoinedGame)
//    {
//        return;
//    }
//    // The idea here is that once we've exchanged pleasantries with a peer,
//    // we ask to join a game if that peer happens to be hosting.
//    NSString *peerID = (NSString *)notification.object;
//    PlayerEnvoy *other = [PlayerEnvoy envoyFromPeerID:peerID];
//    // Paranoia check
//    if (!other)
//    {
//        return;
//    }
//    // If there's no player name, then we don't yet have all the player's info.
//    if (!other.playerName)
//    {
//        return;
//    }
//    JSKCommandMessage *msg = [[JSKCommandMessage alloc] initWithType:JSKCommandMessageTypeJoinGame to:peerID from:[SystemMessage playerEnvoy].peerID];
//    [SystemMessage sendCommandMessage:msg shouldAwaitResponse:YES];
//    [msg release];
}

- (void)peerWasCreated:(NSNotification *)notification
{
//    [self peerWasUpdated:notification];
}

- (void)gameWasJoined:(NSNotification *)notification
{
    [self.timer invalidate];
    self.hasJoinedGame = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate gameJoinerDidFinish:self];
    });
}

- (void)connectedToHost:(NSNotification *)notification
{
    if (self.hasJoinedGame)
    {
        return;
    }
//    [SystemMessage sharedInstance].isLookingForGame = YES;
}

- (void)timerFired:(id)sender
{
    if (self.hasJoinedGame)
    {
        return;
    }
}

@end
