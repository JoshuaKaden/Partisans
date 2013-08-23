//
//  HostFinder.m
//  Partisans
//
//  Created by Joshua Kaden on 6/29/13.
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
