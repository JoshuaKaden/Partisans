//
//  NetHost.m
//  Partisans
//
//  Created by Joshua Kaden on 6/6/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "NetHost.h"

#import "Connection.h"
#import "JSKCommandParcel.h"
#import "SystemMessage.h"


const BOOL kNetHostIsDebugOn = YES;


@interface NetHost()

@property (nonatomic, strong) Server *server;
@property (nonatomic, strong) NSMutableSet *clients;
@property (nonatomic, strong) NSDictionary *stash;
@property (nonatomic, strong) NSDictionary *knownPeerNames;

- (void)handleCommandMessage:(JSKCommandMessage *)commandMessage viaConnection:(Connection *)connection;
- (void)handleCommandParcel:(JSKCommandParcel *)commandParcel viaConnection:(Connection *)connection;

@end


@implementation NetHost

@synthesize delegate = m_delegate;
@synthesize server = m_server;
@synthesize clients = m_clients;
@synthesize stash = m_stash;
@synthesize knownPeerNames = m_knownPeerNames;


- (void)dealloc
{
    [m_server release];
    [m_clients release];
    [m_stash release];
    [m_knownPeerNames release];
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
    
    return YES;
}

- (void)stop
{
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


#pragma mark - Handlers

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
    
    if ([self.delegate respondsToSelector:@selector(netHost:receivedCommandParcel:)])
    {
        [self.delegate netHost:self receivedCommandParcel:commandParcel];
    }
//    else
//    {
//        // Pass it on up the chain.
//        if ([self.delegate respondsToSelector:@selector(peerController:receivedObject:from:)])
//        {
//            [self.delegate peerController:self receivedObject:commandParcel from:commandParcel.from];
//        }
//    }
}

- (void)handleCommandMessage:(JSKCommandMessage *)commandMessage viaConnection:(Connection *)connection
{
    NSString *sessionPeerID = connection.
    NSString *peerID = [self.knownPeerNames valueForKey:sessionPeerID];
    // Special case for Identification messages:
    // Update our dictionary that maps our peer IDs to the Connection's.
    if (commandMessage.commandMessageType == JSKCommandMessageTypeIdentification)
    {
        NSString *peerID = 
        if (!peerID)
        {
            peerID = commandMessage.from;
            
            NSDictionary *existingPeerNames = self.knownPeerNames;
            
            if (existingPeerNames)
            {
                NSMutableDictionary *list = [[NSMutableDictionary alloc] initWithCapacity:existingPeerNames.count + 1];
                [list addEntriesFromDictionary:existingPeerNames];
                [list setValue:peerID forKey:sessionPeerID];
                self.knownPeerNames = [NSDictionary dictionaryWithDictionary:list];
                [list release];
            }
            else
            {
                self.knownPeerNames = [NSDictionary dictionaryWithObjectsAndKeys:peerID, sessionPeerID, nil];
            }
        }
        
        
        // If this peer is subordinate, let's send back our ID.
        if ([self isPeerSubordinate:sessionPeerID])
        {
            JSKCommandMessage *msg = [[JSKCommandMessage alloc] initWithType:JSKCommandMessageTypeIdentification to:peerID from:self.peerID];
            [self sendCommandMessage:msg];
            [msg release];
        }
        else
        {
            // At this stage the delegate may want to handle the identification message.
            // For example, to create a Player record.
            // This is because the subordinate always sends the first ID message.
            // Therefore the ID message that we just received in response to our ID message.
            if ([self.delegate respondsToSelector:@selector(peerController:receivedCommandMessage:)])
            {
                [self.delegate peerController:self receivedCommandMessage:commandMessage];
            }
        }
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(peerController:receivedCommandMessage:)])
    {
        [self.delegate peerController:self receivedCommandMessage:commandMessage];
    }
    else
    {
        // Pass it on up the chain.
        if ([self.delegate respondsToSelector:@selector(peerController:receivedObject:from:)])
        {
            [self.delegate peerController:self receivedObject:commandMessage from:peerID];
        }
    }
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


// One of connected clients sent a chat message. Propagate it further.
- (void)receivedNetworkPacket:(NSObject <NSCoding> *)packet viaConnection:(Connection *)connection
{
    if (kNetHostIsDebugOn)
    {
        debugLog(@"Received network packet:%@\viaConnection:%@", packet, connection);
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
    
//    else
//    {
//        
//        // Pass it on up the chain.
//        if ([self.delegate respondsToSelector:@selector(peerController:receivedObject:from:)])
//        {
//            // The "peer" parameter is GameKit's ID.
//            // We need to match it to our internal peer ID.
//            NSString *peerID = [self.knownPeerNames valueForKey:peer];
//            //                    NSString *peerID = [self.gkSession displayNameForPeer:peer];
//            [self.delegate peerController:self receivedObject:statement from:peerID];
//        }
//    }
    
//    // Display message locally
//    [self.delegate displayChatMessage:[packet objectForKey:@"message"] fromUser:[packet objectForKey:@"from"]];
//    
//    // Broadcast this message to all connected clients, including the one that sent it
//    [self.clients makeObjectsPerformSelector:@selector(sendNetworkPacket:) withObject:packet];
}

@end
