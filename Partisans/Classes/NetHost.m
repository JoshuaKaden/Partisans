//
//  NetHost.m
//  Partisans
//
//  Created by Joshua Kaden on 6/6/13.
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

#import "NetHost.h"

#import "Connection.h"
#import "ConnectionDelegate.h"
#import "JSKCommandParcel.h"
#import "Server.h"
#import "ServerDelegate.h"
#import "SystemMessage.h"


const BOOL kNetHostIsDebugOn = NO;
//const BOOL kNetHostIsDebugOn = YES;


@interface NetHost() <ServerDelegate, ConnectionDelegate>

@property (nonatomic, strong) Server *server;
@property (nonatomic, strong) NSMutableSet *clients;
@property (nonatomic, strong) NSDictionary *stash;
@property (assign) BOOL hasStarted;

- (void)sendObject:(NSObject<NSCoding> *)object to:(NSString *)peerID;
- (void)handleCommandMessage:(JSKCommandMessage *)commandMessage viaConnection:(Connection *)connection;
- (void)handleCommandParcel:(JSKCommandParcel *)commandParcel viaConnection:(Connection *)connection;

@end


@implementation NetHost

@synthesize delegate = m_delegate;
@synthesize server = m_server;
@synthesize clients = m_clients;
@synthesize stash = m_stash;
@synthesize hasStarted = m_hasStarted;


- (void)dealloc
{
    [m_server release];
    [m_clients release];
    [m_stash release];
    [super dealloc];
}

- (BOOL)start
{
    if (self.server)
    {
        return YES;
    }
    
    if (!self.clients)
    {
        NSMutableSet *clients = [[NSMutableSet alloc] initWithCapacity:kPartisansMaxPlayers - 1];
        self.clients = clients;
        [clients release];
    }
    
    Server *server = [[Server alloc] init];
    [server setDelegate:self];
    self.server = server;
    [server release];
    
    if (![self.server start])
    {
        self.server = nil;
        return NO;
    }
    
    self.hasStarted = YES;
    return YES;
}

- (void)stop
{
    self.hasStarted = NO;
    
    [self.server stop];
    [self.server setDelegate:nil];
    self.server = nil;
    
    // Close all connections
    for (Connection *connection in self.clients)
    {
        [connection close];
        [connection setDelegate:nil];
    }
    [self.clients removeAllObjects];
    self.clients = nil;
}


#pragma mark - Private

- (NSString *)buildRandomString
{
    CFUUIDRef udid = CFUUIDCreate(NULL);
    NSString *udidString = (NSString *) CFUUIDCreateString(NULL, udid);
    NSString *returnValue = [NSString stringWithString:udidString];
    [udidString release];
    CFRelease(udid);
    return returnValue;
}

- (void)sendObject:(NSObject<NSCoding> *)object to:(NSString *)peerID
{
    if (!object) {
        return;
    }
    
    if (!peerID) {
        return;
    }
    
    // The "to" parameter is our system's Peer ID.
    // We need to match that to a connection.
    Connection *target = nil;
    for (Connection *connection in self.clients)
    {
        if ([connection.peerID isEqualToString:peerID])
        {
            target = connection;
            break;
        }
    }
    
    if (!target) {
        debugLog(@"Unable to find a connection with the peerID %@", peerID);
        return;
    }
    
    if (kNetHostIsDebugOn)
    {
        debugLog(@"\nSending %@\npeerID %@", object, peerID);
    }
    
    [target sendNetworkPacket:object];
}


#pragma mark - Sending

- (void)sendCommandMessage:(JSKCommandMessage *)commandMessage
{
    [self sendCommandMessage:commandMessage shouldAwaitResponse:NO];
}

- (void)sendCommandMessage:(JSKCommandMessage *)commandMessage shouldAwaitResponse:(BOOL)shouldAwaitResponse
{
    if (!commandMessage) {
        return;
    }
    
    if (shouldAwaitResponse)
    {
        // Stash the message so we can associate the reply when it arrives.
        NSString *responseKey = commandMessage.responseKey;
        if (!responseKey)
        {
            responseKey = [self buildRandomString];
            [commandMessage setResponseKey:responseKey];
        }
        NSDictionary *stash = self.stash;
        if (stash.count == 0)
        {
            self.stash = [NSDictionary dictionaryWithObject:commandMessage forKey:responseKey];
        }
        else
        {
            // Not really sure if this logic branch saves me anything.
            // Or whether it in fact costs me!
            if ([stash valueForKey:responseKey])
            {
                NSMutableDictionary *list = [[NSMutableDictionary alloc] initWithDictionary:stash];
                [list setValue:commandMessage forKey:responseKey];
                self.stash = [NSDictionary dictionaryWithDictionary:list];
                [list release];
            }
            else
            {
                NSMutableDictionary *list = [[NSMutableDictionary alloc] initWithCapacity:stash.count + 1];
                [list addEntriesFromDictionary:stash];
                [list setValue:commandMessage forKey:responseKey];
                self.stash = [NSDictionary dictionaryWithDictionary:list];
                [list release];
            }
        }
    }
    
    [self sendObject:commandMessage to:commandMessage.to];
}


- (void)sendCommandParcel:(JSKCommandParcel *)commandParcel
{
    if (!commandParcel)
    {
        return;
    }
    
    [self sendObject:commandParcel to:commandParcel.to];
}

- (void)sendCommandParcel:(JSKCommandParcel *)commandParcel shouldAwaitResponse:(BOOL)shouldAwaitResponse
{
    if (!commandParcel) {
        return;
    }
    
    if (shouldAwaitResponse)
    {
        // Stash the message so we can associate the reply when it arrives.
        NSString *responseKey = commandParcel.responseKey;
        if (!responseKey)
        {
            responseKey = [self buildRandomString];
            [commandParcel setResponseKey:responseKey];
        }
        NSDictionary *stash = self.stash;
        if (stash.count == 0)
        {
            self.stash = [NSDictionary dictionaryWithObject:commandParcel forKey:responseKey];
        }
        else
        {
            // Not really sure if this logic branch saves me anything.
            // Or whether it in fact costs me!
            if ([stash valueForKey:responseKey])
            {
                NSMutableDictionary *list = [[NSMutableDictionary alloc] initWithDictionary:stash];
                [list setValue:commandParcel forKey:responseKey];
                self.stash = [NSDictionary dictionaryWithDictionary:list];
                [list release];
            }
            else
            {
                NSMutableDictionary *list = [[NSMutableDictionary alloc] initWithCapacity:stash.count + 1];
                [list addEntriesFromDictionary:stash];
                [list setValue:commandParcel forKey:responseKey];
                self.stash = [NSDictionary dictionaryWithDictionary:list];
                [list release];
            }
        }
    }
    
    [self sendObject:commandParcel to:commandParcel.to];
}

- (void)broadcastCommandMessageType:(JSKCommandMessageType)commandMessageType
{
    NSString *myPeerID = [self.delegate netHostPeerID:self];
    for (Connection *connection in self.clients)
    {
        JSKCommandMessage *newCommandMessage = [[JSKCommandMessage alloc] initWithType:commandMessageType to:connection.peerID from:myPeerID];
        [connection sendNetworkPacket:newCommandMessage];
        [newCommandMessage release];
    }
}

- (void)broadcastCommandParcel:(JSKCommandParcel *)commandParcel
{
    for (Connection *connection in self.clients)
    {
        commandParcel.to = connection.peerID;
        [self sendObject:commandParcel to:commandParcel.to];
    }
}


#pragma mark - Data Handlers

- (void)handleCommandParcel:(JSKCommandParcel *)commandParcel viaConnection:(Connection *)connection
{
    if (commandParcel.responseKey)
    {
        // Try to match this response with its waiting message.
        NSObject <NSCoding> *object = nil;
        JSKCommandMessage *msg = [self.stash objectForKey:commandParcel.responseKey];
        object = msg;
        
        // Pass on the parcel to the delegate.
        if (object && [self.delegate respondsToSelector:@selector(netHost:receivedCommandParcel:respondingTo:)])
        {
            [self.delegate netHost:self receivedCommandParcel:commandParcel respondingTo:object];
            
            // Stash management.
            NSMutableDictionary *list = [[NSMutableDictionary alloc] initWithDictionary:self.stash];
            [list setValue:nil forKey:commandParcel.responseKey];
            self.stash = [NSDictionary dictionaryWithDictionary:list];
            [list release];
            
            return;
        }
    }
    
    [self.delegate netHost:self receivedCommandParcel:commandParcel];
}

- (void)handleCommandMessage:(JSKCommandMessage *)commandMessage viaConnection:(Connection *)connection
{
    NSString *peerID = connection.peerID;
    // Special case for Identification messages:
    // Update our dictionary that maps our peer IDs to the Connection's.
    if (commandMessage.commandMessageType == JSKCommandMessageTypeIdentification)
    {
        if (!peerID)
        {
            peerID = commandMessage.from;
            connection.peerID = peerID;
        }
        
        JSKCommandMessage *msg = [[JSKCommandMessage alloc] initWithType:JSKCommandMessageTypeIdentification to:peerID from:[self.delegate netHostPeerID:self]];
        [self sendCommandMessage:msg];
        [msg release];
        return;
    }
    
    [self.delegate netHost:self receivedCommandMessage:commandMessage];
}



#pragma mark - ServerDelegate Method Implementations

// Server has failed. Stop the world.
- (void)serverFailed:(Server *)server reason:(NSString *)reason
{
    // Stop everything and let our delegate know
    [self stop];
    [self.delegate netHost:self terminated:reason];
}


// New client connected to our server. Add it.
- (void)handleNewConnection:(Connection *)connection
{
    if (kNetHostIsDebugOn)
    {
        debugLog(@"\nNew connection: %@", connection);
    }
    
    // Delegate everything to us
    connection.delegate = self;
    
    // Add to our list of clients
    [self.clients addObject:connection];
}


#pragma mark - ConnectionDelegate Method Implementations

// We won't be initiating connections, so this is not important
- (void)connectionAttemptFailed:(Connection *)connection {
}


// One of the clients disconnected, remove it from our list
- (void)connectionTerminated:(Connection *)connection
{
    [connection setDelegate:nil];
    [self.clients removeObject:connection];
}


- (void)receivedNetworkPacket:(NSObject <NSCoding> *)packet viaConnection:(Connection *)connection
{
    if (kNetHostIsDebugOn)
    {
        debugLog(@"\nReceived network packet:%@", packet);
    }
    
    // We're going to interpret them by class name.
    
    // Command Message
    if ([packet isKindOfClass:[JSKCommandMessage class]])
    {
        JSKCommandMessage *commandMessage = (JSKCommandMessage *)packet;
        [self handleCommandMessage:commandMessage viaConnection:connection];
    }
    else if ([packet isKindOfClass:[JSKCommandParcel class]])
    {
        JSKCommandParcel *commandParcel = (JSKCommandParcel *)packet;
        [self handleCommandParcel:commandParcel viaConnection:connection];
    }
    
//    // Display message locally
//    [self.delegate displayChatMessage:[packet objectForKey:@"message"] fromUser:[packet objectForKey:@"from"]];
//    
//    // Broadcast this message to all connected clients, including the one that sent it
//    [self.clients makeObjectsPerformSelector:@selector(sendNetworkPacket:) withObject:packet];
}

- (void)netServiceDidResolveAddress:(Connection *)connection
{
    
}

@end
