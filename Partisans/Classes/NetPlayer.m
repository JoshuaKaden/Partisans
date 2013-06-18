//
//  NetPlayer.m
//  Partisans
//
//  Created by Joshua Kaden on 6/7/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "NetPlayer.h"

#import "Connection.h"
#import "ConnectionDelegate.h"
#import "SystemMessage.h"


const BOOL kNetPlayerIsDebugOn = YES;


@interface NetPlayer () <ConnectionDelegate>

@property (nonatomic, strong) Connection *connection;
@property (nonatomic, strong) NSDictionary *stash;
@property (readwrite) BOOL hasStarted;
@property (nonatomic, assign) BOOL hasAddressBeenResolved;
@property (nonatomic, strong) NSString *hostPeerID;

- (void)sendObject:(NSObject<NSCoding> *)object;
- (void)handleCommandMessage:(JSKCommandMessage *)commandMessage viaConnection:(Connection *)connection;
- (void)handleCommandParcel:(JSKCommandParcel *)commandParcel viaConnection:(Connection *)connection;
- (void)sendID;

@end


@implementation NetPlayer

@synthesize connection = m_connection;
@synthesize delegate = m_delegate;
@synthesize stash = m_stash;
@synthesize hasStarted = m_hasStarted;
@synthesize hasAddressBeenResolved = m_hasAddressBeenResolved;
@synthesize hostPeerID = m_hostPeerID;


- (void)dealloc
{
    [m_stash release];
    [m_connection release];
    [m_hostPeerID release];
    [super dealloc];
}

- (id)initWithHost:(NSString *)host andPort:(int)port
{
    self = [super init];
    if (self)
    {
        Connection *connection = [[Connection alloc] initWithHostAddress:host andPort:port];
        self.connection = connection;
        [connection release];
    }
    return self;
}

- (id)initWithNetService:(NSNetService *)netService
{
    self = [super init];
    if (self)
    {
        Connection *connection = [[Connection alloc] initWithNetService:netService];
        self.connection = connection;
        [connection release];
    }
    return self;
}

- (BOOL)start
{
    if (!self.connection)
    {
        return NO;
    }
    
    [self.connection setDelegate:self];
    self.hasStarted = [self.connection connect];
    return self.hasStarted;
}

- (void)stop
{
    if (!self.connection)
    {
        return;
    }
    [self.connection close];
    [self.connection setDelegate:nil];
    self.hasStarted = NO;
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

- (void)sendObject:(NSObject<NSCoding> *)object
{
    if (!object)
    {
        return;
    }
    
    if (kNetPlayerIsDebugOn)
    {
        debugLog(@"\nSending %@", object);
    }
    
    [self.connection sendNetworkPacket:object];
}

- (void)sendID
{
    NSString *peerID = [self.delegate netPlayerPeerID:self];
    JSKCommandMessage *message = [[JSKCommandMessage alloc] initWithType:JSKCommandMessageTypeIdentification to:nil from:peerID];
    [self sendCommandMessage:message];
    [message release];
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
    
    [self sendObject:commandMessage];
}


- (void)sendCommandParcel:(JSKCommandParcel *)commandParcel
{
    if (!commandParcel)
    {
        return;
    }
    
    [self sendObject:commandParcel];
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
    
    [self sendObject:commandParcel];
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
        if (object)
        {
            [self.delegate netPlayer:self receivedCommandParcel:commandParcel respondingTo:object];
            
            // Stash management.
            NSMutableDictionary *list = [[NSMutableDictionary alloc] initWithDictionary:self.stash];
            [list setValue:nil forKey:commandParcel.responseKey];
            self.stash = [NSDictionary dictionaryWithDictionary:list];
            [list release];
            
            return;
        }
    }
    
    [self.delegate netPlayer:self receivedCommandParcel:commandParcel];
}

- (void)handleCommandMessage:(JSKCommandMessage *)commandMessage viaConnection:(Connection *)connection
{
    // We'll handle an ID message ourselves.
    if (commandMessage.commandMessageType == JSKCommandMessageTypeIdentification)
    {
        // Make note of the host's peer ID.
        NSString *hostID = commandMessage.from;
        if (hostID)
        {
            self.connection.peerID = hostID;
            self.hostPeerID = hostID;
        }
        // Send the host our player's modification date.
        // The host will request our data if it needs it.
        NSString *peerID = [self.delegate netPlayerPeerID:self];
        NSDate *modifiedDate = [self.delegate netPlayerModifiedDate:self];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:modifiedDate, @"modifiedDate", @"Player", @"entity", nil];
        JSKCommandParcel *parcel = [[JSKCommandParcel alloc] initWithType:JSKCommandParcelTypeModifiedDate to:hostID from:peerID object:dictionary];
        [self sendCommandParcel:parcel];
        [parcel release];
        
        return;
    }
    
    [self.delegate netPlayer:self receivedCommandMessage:commandMessage];
}



#pragma mark - Connection delegate

- (void)connectionAttemptFailed:(Connection *)connection
{
    NSString *reason = NSLocalizedString(@"Unable to connect to the host.", @"Unable to connect to the host.  --  alert message");
    [self.delegate netPlayer:self terminated:reason];
}


- (void)connectionTerminated:(Connection *)connection
{
    NSString *reason = NSLocalizedString(@"The connection to the host was closed.", @"The connection to the host was closed.  --  alert message");
    [self.delegate netPlayer:self terminated:reason];
}


- (void)receivedNetworkPacket:(NSDictionary *)packet viaConnection:(Connection *)connection
{
    if (kNetPlayerIsDebugOn)
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
}

- (void)netServiceDidResolveAddress:(Connection *)connection
{
    self.hasAddressBeenResolved = YES;
    [self.delegate netPlayerDidResolveAddress:self];
}


@end
