//
//  HostFinder.m
//  Partisans
//
//  Created by Joshua Kaden on 6/29/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "HostFinder.h"

#import "GameEnvoy.h"
#import "PlayerEnvoy.h"
#import "SystemMessage.h"

@interface HostFinder ()

@property (nonatomic, assign) BOOL isConnected;
@property (nonatomic, strong) NSString *hostPeerID;
@property (nonatomic, strong) NSTimer *timer;

- (void)hostReadyToCommunicate:(NSNotification *)notification;
- (void)timerFired:(id)sender;

@end


@implementation HostFinder

@synthesize delegate = m_delegate;
@synthesize isConnected = m_isConnected;
@synthesize hostPeerID = m_hostPeerID;
@synthesize timer = m_timer;
@synthesize timerInterval = m_timeout;


- (void)dealloc
{
    [self.timer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [m_hostPeerID release];
    [m_timer release];
    [super dealloc];
}

- (BOOL)isConnected
{
    self.isConnected = [SystemMessage isPlayerOnline];
    return m_isConnected;
}

- (NSString *)hostPeerID
{
    self.hostPeerID = [SystemMessage gameEnvoy].host.peerID;
    return m_hostPeerID;
}

- (void)connect
{
    if ([SystemMessage isPlayerOnline])
    {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hostReadyToCommunicate:) name:kPartisansNotificationHostReadyToCommunicate object:nil];
    
    [SystemMessage putPlayerOnline];
    
    if (!self.timer)
    {
        if (self.timerInterval == 0)
        {
            self.timerInterval = 10.0;
        }
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.timerInterval target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
        self.timer = timer;
    }
}

- (void)stop
{
    [self.timer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)hostReadyToCommunicate:(NSNotification *)notification
{
    NSString *hostPeerID = notification.object;
    [self.delegate hostFinder:self isConnectedToHost:hostPeerID];
}

- (void)timerFired:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(hostFinderTimerFired:)])
    {
        [self.delegate hostFinderTimerFired:self];
    }
}

@end
