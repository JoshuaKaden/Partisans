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
#import "ServerBrowser.h"
#import "ServerBrowserDelegate.h"
#import "SystemMessage.h"


@interface GameJoiner () <ServerBrowserDelegate>

@property (readwrite) BOOL isScanning;
@property (readwrite) BOOL hasJoinedGame;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) ServerBrowser *serverBrowser;

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
@synthesize serverBrowser = m_serverBrowser;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.timer invalidate];
    [self.serverBrowser setDelegate:nil];
    
    [m_timer release];
    [m_serverBrowser release];
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
    
    ServerBrowser *serverBrowser = [[ServerBrowser alloc] init];
    [serverBrowser setDelegate:self];
    self.serverBrowser = serverBrowser;
    [self.serverBrowser start];
    
    if (!self.timer)
    {
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
        self.timer = timer;
    }
}

- (void)stopScanning
{
    [self.serverBrowser stop];
    [self.serverBrowser setDelegate:nil];
    self.serverBrowser = nil;
    
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
    [SystemMessage sharedInstance].isLookingForGame = YES;
    [SystemMessage sendToHost:JSKCommandMessageTypeIdentification shouldAwaitResponse:YES];
}

- (void)timerFired:(id)sender
{
    if (self.hasJoinedGame)
    {
        return;
    }
}

#pragma mark - ServerBrowser delegate

- (void)updateServerList
{
    NSArray *servers = self.serverBrowser.servers;
//    [self.serverBrowser stop];
    debugLog(@"ServerBrowser found: %@", servers);
    for (NSNetService *service in servers)
    {
        if ([service.name isEqualToString:kPartisansNetServiceName])
        {
            if ([SystemMessage connectToService:service])
            {
//                [SystemMessage sendToHost:JSKCommandMessageTypeIdentification shouldAwaitResponse:YES];
            }
            break;
        }
    }
//    [self.serverBrowser start];
}

@end
