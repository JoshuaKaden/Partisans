//
//  JSKPeerController.m
//  Partisans
//
//  Created by Joshua Kaden on 4/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "JSKPeerController.h"

//#import "NSArray+SubArrays.h"
#import "JSKSystemMessage.h"


const BOOL kJSKPeerControllerIsDebugOn = YES;
const NSUInteger PeerMessageSizeLimit = 10000;


@interface JSKPeerController ()

@property (nonatomic, strong) GKSession *gkSession;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, assign) BOOL isSending;
@property (readwrite, nonatomic, strong) NSString *myPeerID;
@property (nonatomic, strong) NSDictionary *knownPeerNames;
@property (atomic, assign) BOOL isSlave;
@property (atomic, strong) NSDictionary *stash;
@property (atomic, strong) NSDictionary *customStash;
@property (atomic, strong) NSDictionary *outbox;

- (BOOL)hasSessionStarted;
- (void)archiveAndSend:(NSObject <NSCoding> *)object toSessionPeerID:(NSString *)sessionPeerID;
- (void)handleCommandMessage:(JSKCommandMessage *)commandMessage fromSessionPeerID:(NSString *)sessionPeerID;
- (void)handleCommandParcel:(JSKCommandParcel *)commandParcel fromSessionPeerID:(NSString *)sessionPeerID;
- (NSString *)buildRandomString;
- (BOOL)isPeerSubordinate:(NSString *)sessionPeerID;
- (void)sendCommandMessage:(JSKCommandMessage *)msg toSessionPeerID:(NSString *)sessionPeerID shouldAwaitResponse:(BOOL)shouldAwaitResponse;
- (void)saveToOutbox:(NSObject <NSCoding> *)object toSessionPeerID:(NSString *)sessionPeerID;
- (void)clearOutbox:(NSString *)sessionPeerID;

@end


@implementation JSKPeerController

@synthesize gkSession = m_gkSession;
@synthesize queue = m_queue;
@synthesize isSending = m_isSending;
@synthesize myPeerID = m_myPeerID;
@synthesize delegate = m_delegate;
@synthesize knownPeerNames = m_knownPeerNames;
@synthesize peerID = m_peerID;
@synthesize isSlave = m_isSlave;
@synthesize stash = m_stash;
@synthesize customStash = m_customStash;
@synthesize outbox = m_outbox;



#pragma mark - Lifecycle


- (void)dealloc
{
    [m_gkSession setDelegate:nil];
    
    [m_gkSession release];
    [m_queue release];
    [m_myPeerID release];
    [m_knownPeerNames release];
    [m_peerID release];
    [m_stash release];
    [m_customStash release];
    [m_outbox release];
    
    [super dealloc];
}

- (BOOL)isPeerSubordinate:(NSString *)sessionPeerID
{
    if (!self.gkSession)
    {
        return NO;
    }
    
    NSString *peerID = self.gkSession.peerID;

    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber *ourNumber = [formatter numberFromString:peerID];
    NSNumber *theirNumber = [formatter numberFromString:sessionPeerID];
    [formatter release];

    if (kJSKPeerControllerIsDebugOn)
    {
        debugLog(@"ourID:%@ theirID:%@", peerID, sessionPeerID);
        if ([ourNumber intValue] > [theirNumber intValue])
        {
            debugLog(@"They are subordinate");
        }
        else
        {
            debugLog(@"We are subordinate");
        }
    }
    
    if ([ourNumber intValue] > [theirNumber intValue])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


- (BOOL)hasSessionStarted
{
    if (!self.gkSession)
    {
        return NO;
    }
    
    return self.gkSession.isAvailable;
}


- (void)startSession
{
    if (!self.knownPeerNames)
    {
        self.knownPeerNames = [NSDictionary dictionary];
    }
    
    if (!self.stash)
    {
        self.stash = [NSDictionary dictionary];
    }
    
    NSString *sessionID = @"ThoroughlyRandomSessionIDForPartisans";
    NSString *peerID = self.myPeerID;
    
    GKSession *gkSession = [[GKSession alloc] initWithSessionID:sessionID displayName:peerID sessionMode:GKSessionModePeer];
    
    [gkSession setDelegate:self];
    [gkSession setDataReceiveHandler:self withContext:nil];
//    [gkSession setDataReceiveHandler:self withContext:gkSession];
    
    self.gkSession = gkSession;
    [gkSession release];
    
    if (kJSKPeerControllerIsDebugOn)
    {
        debugLog(@"Initiating p2p session with ID: %@ as peer: %@", sessionID, peerID);
    }
    [self.gkSession setAvailable:YES];
}


- (void)stopSession {
    
    if (m_queue) {
        if (m_queue.operationCount > 0) {
            [m_queue waitUntilAllOperationsAreFinished];
            //            [m_queue cancelAllOperations];
            [m_queue removeObserver:self forKeyPath:@"operations"];
        }
    }
    
    if (self.gkSession.available) {
        [self.gkSession disconnectFromAllPeers];
        self.gkSession.available = NO;
    }
    self.gkSession.delegate = nil;
    self.gkSession = nil;
    
    self.knownPeerNames = nil;
    self.stash = nil;
    self.customStash = nil;
}


- (void)resetPeerID
{
    [self stopSession];
    [self setMyPeerID:nil];
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
//    // Create universally unique identifier (object)
//    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
//    
//    // Get the string representation of CFUUID object.
//    NSString *uuidStr = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
//    CFRelease(uuidObject);
//    
//    NSString *returnValue = [NSString stringWithString:uuidStr];
//    [uuidStr release];
//    return returnValue;
}

- (void)saveToOutbox:(NSObject<NSCoding> *)object toSessionPeerID:(NSString *)sessionPeerID
{
    // Save the outgoing object in the outbox.
    NSDictionary *outbox = self.outbox;
    if (outbox.count == 0)
    {
        self.outbox = [NSDictionary dictionaryWithObject:[NSArray arrayWithObject:object] forKey:sessionPeerID];
    }
    else
    {
        // Fussy logic here to control the dictionary of arrays.
        // One array of objects for each intended recipient (sessionPeerID).
        if ([outbox valueForKey:sessionPeerID])
        {
            NSArray *objects = (NSArray *)[outbox valueForKey:sessionPeerID];
            if (objects.count > 0)
            {
                objects = [objects arrayByAddingObject:object];
            }
            NSMutableDictionary *list = [[NSMutableDictionary alloc] initWithDictionary:outbox];
            [list setValue:objects forKey:sessionPeerID];
            self.outbox = [NSDictionary dictionaryWithDictionary:list];
            [list release];
        }
        else
        {
            NSMutableDictionary *list = [[NSMutableDictionary alloc] initWithCapacity:outbox.count + 1];
            [list addEntriesFromDictionary:outbox];
            [list setValue:[NSArray arrayWithObject:object] forKey:sessionPeerID];
            self.outbox = [NSDictionary dictionaryWithDictionary:list];
            [list release];
        }
    }
}

- (void)clearOutbox:(NSString *)sessionPeerID
{
    NSMutableDictionary *outboxList = [[NSMutableDictionary alloc] initWithDictionary:self.outbox];
    if (!outboxList)
    {
        return;
    }
    [outboxList setValue:nil forKey:sessionPeerID];
    self.outbox = [NSDictionary dictionaryWithDictionary:outboxList];
    [outboxList release];
}


#pragma mark - Overrides

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self.queue && [keyPath isEqualToString:@"operations"])
    {
        if ([self.queue.operations count] == 0)
        {
            // The queue has completed.
            if ([self.delegate respondsToSelector:@selector(peerControllerQueueHasEmptied:)]) {
                [self.delegate peerControllerQueueHasEmptied:self];
            }
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}



#pragma mark - Sending


- (void)sendObject:(NSObject<NSCoding> *)object to:(NSString *)peerID
{
    [self sendObject:object to:peerID shouldAwaitResponse:NO];
}

- (void)sendObject:(NSObject<NSCoding> *)object to:(NSString *)peerID shouldAwaitResponse:(BOOL)shouldAwaitResponse
{
    if (!object) {
        return;
    }
    
    if (shouldAwaitResponse)
    {
        // Stash the message so we can associate the reply when it arrives.
        NSString *responseKey = nil;
        if ([object respondsToSelector:@selector(responseKey)])
        {
            responseKey = [object valueForKey:@"responseKey"];
        }
        else
        {
            return;
        }
        
        if (!responseKey)
        {
            responseKey = [self buildRandomString];
            [object setValue:responseKey forKey:@"responseKey"];
        }
        NSDictionary *stash = self.customStash;
        if (stash.count == 0)
        {
            self.stash = [NSDictionary dictionaryWithObject:object forKey:responseKey];
        }
        else
        {
            // Not really sure if this logic branch saves me anything.
            // Or whether it in fact costs me!
            if ([stash valueForKey:responseKey])
            {
                NSMutableDictionary *list = [[NSMutableDictionary alloc] initWithDictionary:stash];
                [list setValue:object forKey:responseKey];
                self.stash = [NSDictionary dictionaryWithDictionary:list];
                [list release];
            }
            else
            {
                NSMutableDictionary *list = [[NSMutableDictionary alloc] initWithCapacity:stash.count + 1];
                [list addEntriesFromDictionary:stash];
                [list setValue:object forKey:responseKey];
                self.stash = [NSDictionary dictionaryWithDictionary:list];
                [list release];
            }
        }
    }
    
    [self archiveAndSend:object to:peerID];
}

- (void)broadcastCommandMessage:(JSKCommandMessageType)commandMessageType toPeerIDs:(NSArray *)peerIDs
{
    for (NSString *peerID in peerIDs)
    {
        JSKCommandMessage *newCommandMessage = [[JSKCommandMessage alloc] initWithType:commandMessageType to:peerID from:self.peerID];
        [self sendCommandMessage:newCommandMessage];
        [newCommandMessage release];
    }
}


- (void)broadcastCommandMessageType:(JSKCommandMessageType)commandMessageType
{
    [self broadcastCommandMessage:commandMessageType toPeerIDs:[self.knownPeerNames allValues]];
}


- (void)archiveAndBroadcast:(NSObject <NSCoding> *)object
{
    for (NSString *peerID in [self.knownPeerNames allValues])
//  for (NSString *peerID in [self.gkSession peersWithConnectionState:GKPeerStateConnected])
    {
        [self archiveAndSend:object to:peerID];
    }
}



//- (void)sendCommandMessage:(CommandMessage *)commandMessage completionHandler:(void (^)(NSDictionary *, NSError *))completionBlock {
//
//    [self sendCommandMessage:commandMessage];
//
//
//}


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
    
    [self archiveAndSend:commandMessage to:commandMessage.to];
}


- (void)sendCommandMessage:(JSKCommandMessage *)msg toSessionPeerID:(NSString *)sessionPeerID shouldAwaitResponse:(BOOL)shouldAwaitResponse
{
    
}



- (void)sendCommandParcel:(JSKCommandParcel *)commandParcel
{
    if (!commandParcel)
    {
        return;
    }
    
    [self archiveAndSend:commandParcel to:commandParcel.to];
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
    
    [self archiveAndSend:commandParcel to:commandParcel.to];
}


- (void)archiveAndSend:(NSObject <NSCoding> *)object toSessionPeerID:(NSString *)sessionPeerID
{
    // If we're connected, go ahead and send.
    // If we're not connected, put the object in the outbox, and connect.
    BOOL isConnected = NO;
    NSArray *connected = [self.gkSession peersWithConnectionState:GKPeerStateConnected];
    for (NSString *peer in connected)
    {
        if ([peer isEqualToString:sessionPeerID])
        {
            isConnected = YES;
            break;
        }
    }
    
    if (!isConnected)
    {
        // Save to outbox.
        [self saveToOutbox:object toSessionPeerID:sessionPeerID];
        // Connect.
        NSString *peerName = [self.knownPeerNames valueForKey:sessionPeerID];
        if (kJSKPeerControllerIsDebugOn)
        {
            debugLog(@"Connecting to peer:%@ named:%@", sessionPeerID, peerName);
        }
        [self.gkSession connectToPeer:sessionPeerID withTimeout:20];
        return;
    }
    
    // For now just send the data.
    // Worry about big messages later, if needs be.
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
    
    if (kJSKPeerControllerIsDebugOn)
    {
        debugLog(@"Will send a message of %d bytes to peer %@.", data.length, sessionPeerID);
        debugLog(@"Sending: %@", object);
//        debugLog(@"Sending raw: %@", data);
    }
    
//    NSArray *sendDataArray = [NSArray arrayWithObject:data];
    
    
    //    NSArray *test = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    //    debugLog(@"Testing archive: %@", test);
    
    
    //    // Assemble the message into digestable chunks.
    //    NSMutableArray *sendDataList = [[NSMutableArray alloc] init];
    //
    //    NSArray *addArray = objectsToBeSent;
    //    if (addArray.count > 0) {
    //        NSUInteger itemSize = [self arrayItemDataSize:addArray];
    //        if (itemSize * addArray.count > PeerMessageSizeLimit) {
    //            NSArray *subArrays = [addArray subArraysOfLength:PeerMessageSizeLimit / itemSize];
    //            for (NSArray *subArray in subArrays) {
    //                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:subArray];
    //                debugLog(@"Will send a partial peer message of %d bytes.", data.length);
    //                [sendDataList addObject:data];
    //            }
    //        }
    //        else {
    //
    //            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:addArray];
    //            debugLog(@"Will send an entire peer message of %d bytes to %@.", data.length, peerID);
    //            [sendDataList addObject:data];
    //        }
    //    }
    //
    //
    //
    //    NSArray *sendDataArray = [NSArray arrayWithArray:sendDataList];
    
    
    // Queue up the message for sending.
    NSOperationQueue *queue = self.queue;
    
    //    NSOperation *op = [[NSOperation alloc] init];
    //    [op set]
    
    [queue addOperationWithBlock:^(void) {
        
        self.isSending = YES;
        
//        for (NSData *dataToSend in sendDataArray) {
        
            NSError *sendError = nil;
            
            
//            NSArray *decodedArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataToSend];
//            debugLog(@"decoded array %@", decodedArray);
            
            
            [self.gkSession sendData:data toPeers:[NSArray arrayWithObject:sessionPeerID] withDataMode:GKSendDataReliable error:&sendError];
            
            if (sendError) {
                // Oops, an error.
                debugLog(@"An error occurred sending peer data: %@.", sendError);
                self.isSending = NO;
                return;
            }
//        }
        
        self.isSending = NO;
    }];
}


- (void)archiveAndSend:(NSObject <NSCoding> *)object to:(NSString *)to
{
    if (!object) {
        return;
    }
    
    if (!to) {
        return;
    }
    
    
    
    // The "to" parameter is our system's Peer ID.
    // We need to match that to an ID that GKSession knows about.
    NSString *peerID = nil;
    NSArray *peerKeys = [self.knownPeerNames allKeys];
    for (NSString *peerKey in peerKeys)
    {
        NSString *peerValue = [self.knownPeerNames valueForKey:peerKey];
        if ([peerValue isEqualToString:to])
        {
            peerID = peerKey;
            break;
        }
    }
    
//    NSString *peerID = [self.connectedPeerNames valueForKey:to];
//    if (!peerID) {
//
//        for (NSString *aPeerID in [self.gkSession peersWithConnectionState:GKPeerStateConnected]) {
//
//            if ([[self.gkSession displayNameForPeer:aPeerID] isEqualToString:to]) {
//
//                peerID = aPeerID;
//                break;
//            }
//        }
//    }


    if (!peerID) {
        debugLog(@"Unable to find a peer ID for the name %@", to);
        return;
    }
    
    
     

    [self archiveAndSend:object toSessionPeerID:peerID];
}



- (NSUInteger)arrayItemDataSize:(NSArray *)array {
    
    if (!array) {
        return 0;
    }
    
    if (array.count == 0) {
        return 0;
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
    return data.length / array.count;
}


//- (NSArray *)peerIDList {
//    return [self.gkSession peersWithConnectionState:GKPeerStateConnected];
//}




#pragma mark - PeerDataHandler

- (void)handleCommandParcel:(JSKCommandParcel *)commandParcel fromSessionPeerID:(NSString *)sessionPeerID
{
    // The "sessionPeerID" parameter is GameKit's ID.
    // We need to match it to our internal peer ID.
    NSString *peerID = [self.knownPeerNames valueForKey:sessionPeerID];
    if (!peerID)
    {
        return;
    }
    
    if (commandParcel.responseKey)
    {
        // Try to match this response with its waiting message.
        NSObject <NSCoding> *object = nil;
        BOOL isCustom = NO;
        JSKCommandMessage *msg = [self.stash objectForKey:commandParcel.responseKey];
        if (!msg)
        {
            // Try the custom object stash.
            object = [self.customStash objectForKey:commandParcel.responseKey];
        }
        if (object)
        {
            isCustom = YES;
        }
        else
        {
            object = msg;
        }
        // Pass on the parcel to the delegate.
        if ([self.delegate respondsToSelector:@selector(peerController:receivedCommandParcel:respondingTo:)])
        {
            [self.delegate peerController:self receivedCommandParcel:commandParcel respondingTo:object];

            // Stash management.
            if (isCustom)
            {
                NSMutableDictionary *customList = [[NSMutableDictionary alloc] initWithDictionary:self.customStash];
                [customList setValue:nil forKey:commandParcel.responseKey];
                self.customStash = [NSDictionary dictionaryWithDictionary:customList];
                [customList release];
            }
            else
            {
                NSMutableDictionary *list = [[NSMutableDictionary alloc] initWithDictionary:self.stash];
                [list setValue:nil forKey:commandParcel.responseKey];
                self.stash = [NSDictionary dictionaryWithDictionary:list];
                [list release];
            }
            
            return;
        }
    }



    if ([self.delegate respondsToSelector:@selector(peerController:receivedCommandParcel:)])
    {
        [self.delegate peerController:self receivedCommandParcel:commandParcel];
    }
    else
    {
        // Pass it on up the chain.
        if ([self.delegate respondsToSelector:@selector(peerController:receivedObject:from:)])
        {
            [self.delegate peerController:self receivedObject:commandParcel from:commandParcel.from];
        }
    }
}

- (void)handleCommandMessage:(JSKCommandMessage *)commandMessage fromSessionPeerID:(NSString *)sessionPeerID
{
    // The "sessionPeerID" parameter is GameKit's ID.
    // We need to match it to our internal peer ID.
    NSString *peerID = [self.knownPeerNames valueForKey:sessionPeerID];
    
    // Special case for Identification messages:
    // Update our dictionary that maps our peer IDs to GameKit's.
    if (commandMessage.commandMessageType == JSKCommandMessageTypeIdentification)
    {
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
//            if ([self.delegate respondsToSelector:@selector(peerController:connectedToPeer:)])
//            {
//                [self.delegate peerController:self connectedToPeer:peerID];
//            }
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


- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context
{
//    debugLog(@"Received message of %d bytes from peer %@.", data.length, peer);
    
    NSObject <NSCoding> *statement = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    debugLog(@"Received object from peer %@.\nThe object:\n%@", peer, statement);
    
    //    debugLog(@"Received raw: %@", data);
    
    
    // We're going to interpret them by class name.
    
    // Command Message
    if ([statement isKindOfClass:[JSKCommandMessage class]])
    {
        JSKCommandMessage *commandMessage = (JSKCommandMessage *)statement;
        [self handleCommandMessage:commandMessage fromSessionPeerID:peer];
    }
    else if ([statement isKindOfClass:[JSKCommandParcel class]])
    {
        JSKCommandParcel *commandParcel = (JSKCommandParcel *)statement;
        [self handleCommandParcel:commandParcel fromSessionPeerID:peer];
    }
    else
    {
        
        // Pass it on up the chain.
        if ([self.delegate respondsToSelector:@selector(peerController:receivedObject:from:)])
        {
            // The "peer" parameter is GameKit's ID.
            // We need to match it to our internal peer ID.
            NSString *peerID = [self.knownPeerNames valueForKey:peer];
            //                    NSString *peerID = [self.gkSession displayNameForPeer:peer];
            [self.delegate peerController:self receivedObject:statement from:peerID];
        }
    }
    
    
    // Or, a more defensive option...
    //            else {
    //
    //                // Do nothing.
    //                debugLog(@"Unexpected class: %@", arrayItem.description);
    //            }
    
    
//    // Is this an array?
//    if ([statement isKindOfClass:[NSArray class]])
//    {
//        NSArray *array = (NSArray *)statement;
//        
//        for (NSObject *arrayItem in array)
//        {
//            // Now we're looping through the sent messages.
//            // We're going to interpret them by class name.
//            
//            // Command Message
//            if ([arrayItem isKindOfClass:[JSKCommandMessage class]])
//            {
//                JSKCommandMessage *commandMessage = (JSKCommandMessage *)arrayItem;
//                [self handleCommandMessage:commandMessage fromSessionPeerID:peer];
//            }
//            else if ([arrayItem isKindOfClass:[JSKCommandParcel class]])
//            {
//                JSKCommandParcel *commandResponse = (JSKCommandParcel *)arrayItem;
//                [self handleCommandResponse:commandResponse fromSessionPeerID:peer];
//            }
//            else
//            {
//                // Pass it on up the chain.
//                if ([self.delegate respondsToSelector:@selector(peerController:receivedObject:from:)])
//                {
//                    // The "peer" parameter is GameKit's ID.
//                    // We need to match it to our internal peer ID.
//                    NSString *peerID = [self.connectedPeerNames valueForKey:peer];
////                    NSString *peerID = [self.gkSession displayNameForPeer:peer];
//                    [self.delegate peerController:self receivedObject:arrayItem from:peerID];
//                }
//            }
//            
//            
//            // Or, a more defensive option...
//            //            else {
//            //
//            //                // Do nothing.
//            //                debugLog(@"Unexpected class: %@", arrayItem.description);
//            //            }
//        }
//    }
//    else
//    {
//        // Not an array.
//        debugLog(@"Unexpectedly received an object with no container array from peer %@.\nThe object:\n%@", peer, statement);
//    }
}



#pragma mark - Custom accessors



- (NSOperationQueue *)queue {
    
    if (m_queue) {
        return m_queue;
    }
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue setName:@"com.sweetheartsoftware.peerControllerQueue"];
    [queue setMaxConcurrentOperationCount:1];
    [queue addObserver:self forKeyPath:@"operations" options:0 context:NULL];
    self.queue = queue;
    [queue release];
    
    return m_queue;
}


- (NSString *)myPeerID {
    
    if (m_myPeerID) {
        return m_myPeerID;
    }
    
    
    if ([JSKSystemMessage myPeerID]) {
        [self setMyPeerID:[JSKSystemMessage myPeerID]];
        return m_myPeerID;
    }
    
    NSString *myPeerID = [self buildRandomString];
    self.myPeerID = myPeerID;
//    [self setMyPeerID:[self buildRandomString]];
//    // Create universally unique identifier (object)
//    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
//    
//    // Get the string representation of CFUUID object.
//    NSString *uuidStr = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
//    CFRelease(uuidObject);
//    
//    [self setMyPeerID:uuidStr];
//    [uuidStr release];
    
    [[JSKSystemMessage sharedInstance] setMyPeerID:m_myPeerID];
    // Save the peer ID in user defaults.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:m_myPeerID forKey:@"myPeerID"];
    
    return m_myPeerID;
}



#pragma mark - GKSessionDelegate Methods


- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    NSString *peerName = [self.knownPeerNames valueForKey:peerID];
    if (kJSKPeerControllerIsDebugOn)
    {
        debugLog(@"Connection request from peer:%@ named:%@", peerID, peerName);
    }
    
//    if (self.isSlave)
//    {
//        return;
//    }
    
    NSError *error = nil;
    if (![session acceptConnectionFromPeer:peerID error:&error]) {
        debugLog(@"Problem connecting to peer: %@",peerID);
        return;
    }
    
//    self.isSlave = YES;
}



- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    NSString *peerName = [self.knownPeerNames valueForKey:peerID];
    
    switch (state)
    {
        case GKPeerStateAvailable:
            if (kJSKPeerControllerIsDebugOn)
            {
                debugLog(@"Peer is available:%@ named:%@", peerID, peerName);
            }
            
            // If we see a superior peer, we automatically send them our name.
            // They will appreciate this, as it enables us to address each other, using our own names.
            // In other words, it is the beginning of our protocol.
            if (![self isPeerSubordinate:peerID])
            {
                NSString *ourPeerID = [self.knownPeerNames valueForKey:peerID];
                if (!ourPeerID)
                {
                    JSKCommandMessage *msg = [[JSKCommandMessage alloc] initWithType:JSKCommandMessageTypeIdentification to:nil from:self.peerID];
                    [self archiveAndSend:msg toSessionPeerID:peerID];
                    [msg release];
                }
            }
//            if ([self isPeerSubordinate:peerID])
//            {
//                if (kJSKPeerControllerIsDebugOn)
//                {
//                    debugLog(@"Connecting to peer:%@ named:%@", peerID, peerName);
//                }
//                [session connectToPeer:peerID withTimeout:20];
//            }
            break;
            
        case GKPeerStateConnected:
        {
            if ([self isPeerSubordinate:peerID])
            {
                if (kJSKPeerControllerIsDebugOn)
                {
                    debugLog(@"Connected to subordinate peer:%@ named:%@", peerID, peerName);
                }
            }
            else
            {
                if (kJSKPeerControllerIsDebugOn)
                {
                    debugLog(@"Connected to superior peer:%@ named:%@", peerID, peerName);
                }
//                // Once we connect to a superior peer, we automatically send them our name.
//                // They will appreciate this, as it enables us to address each other, using our own names.
//                NSString *ourPeerID = [self.connectedPeerNames valueForKey:peerID];
//                if (!ourPeerID)
//                {
//                    JSKCommandMessage *msg = [[JSKCommandMessage alloc] initWithType:JSKCommandMessageTypeIdentification to:nil from:self.peerID];
//                    [self archiveAndSend:msg toSessionPeerID:peerID];
//                    [msg release];
//                }
            }
            
            NSArray *outboxObjects = [self.outbox valueForKey:peerID];
            if (outboxObjects)
            {
                // Clear out the outbox.
                [self clearOutbox:peerID];
                // Loop through and send the outboxed objects.
                for (NSObject <NSCoding> *object in outboxObjects)
                {
                    if (kJSKPeerControllerIsDebugOn)
                    {
                        debugLog(@"Preparing to send outboxed object to %@", peerID);
                    }
                    [self archiveAndSend:object toSessionPeerID:peerID];
                }
            }
            
            break;
        }
        
        
        case GKPeerStateConnecting:
            if (kJSKPeerControllerIsDebugOn)
            {
                debugLog(@"Connection from:%@ named:%@", peerID, peerName);
            }
            break;
            
            
        case GKPeerStateDisconnected:
        {
            if (kJSKPeerControllerIsDebugOn)
            {
                debugLog(@"Disconnected from peer:%@ named:%@", peerID, peerName);
            }
//            NSDictionary *existingPeerNames = self.connectedPeerNames;
//            if (existingPeerNames)
//            {
//                if ([existingPeerNames valueForKey:peerName])
//                {
//                    NSMutableDictionary *list = [[NSMutableDictionary alloc] initWithCapacity:existingPeerNames.count];
//                    [list addEntriesFromDictionary:existingPeerNames];
//                    [list setValue:nil forKey:peerName];
//                    self.connectedPeerNames = [NSDictionary dictionaryWithDictionary:list];
//                    [list release];
//                }
//            }
//            [session connectToPeer:peerID withTimeout:20];
            break;
        }
            
            
        case GKPeerStateUnavailable:
            if (kJSKPeerControllerIsDebugOn)
            {
                debugLog(@"Peer is unavailable:%@ named:%@", peerID, peerName);
            }
            break;
    }
    
////    NSString *peerDisplayName = peerID;
////    NSString *peerDisplayName = [session displayNameForPeer:peerID];
//    
//    if (peerID) // && peerName)
//    {
//        //        debugLog(@"Peer %@ state changed to: %i", peerDisplayName, state);
//        
//        
//        //        NSDictionary *existingPeerNames = nil;
//        //        if (self.connectedPeerNames) {
//        //            existingPeerNames = [NSDictionary dictionaryWithDictionary:self.connectedPeerNames];
//        //        }
//        
//        
//        
//        
//        //        if (!self.connectedPeerNames) {
//        //            NSMutableDictionary *connectedPeerNames = [[NSMutableDictionary alloc] initWithCapacity:10];
//        //            self.connectedPeerNames = connectedPeerNames;
//        //            [connectedPeerNames release];
//        //        }
//        
//        switch (state) {
//                
//                
//            case GKPeerStateAvailable:
//                [session connectToPeer:peerID withTimeout:20];
//                break;
//                
//                
//            case GKPeerStateConnected:
//            {
////                debugLog(@"Connected to peer:%@ named:%@", peerID, peerDisplayName);
//                
//                // Once we connect to a peer, we automatically send them our name.
//                // They will appreciate this, as it enables us to address each other, using our own names.
//                NSString *ourPeerID = [self.connectedPeerNames valueForKey:peerID];
//                if (!ourPeerID)
//                {
//                    JSKCommandMessage *msg = [[JSKCommandMessage alloc] initWithType:JSKCommandMessageTypeIdentification to:peerName from:self.peerID];
//                    [self archiveAndSend:msg toSessionPeerID:peerID];
//                    [msg release];
//                }
//                break;
//                
////                NSDictionary *existingPeerNames = self.connectedPeerNames;
////                
////                if (existingPeerNames)
////                {
////                    if (![existingPeerNames valueForKey:peerDisplayName])
////                    {
////                        NSMutableDictionary *list = [[NSMutableDictionary alloc] initWithCapacity:existingPeerNames.count + 1];
////                        [list addEntriesFromDictionary:existingPeerNames];
////                        [list setValue:peerID forKey:peerDisplayName];
////                        self.connectedPeerNames = [NSDictionary dictionaryWithDictionary:list];
////                        [list release];
////                    }
////                }
////                else
////                {
////                    self.connectedPeerNames = [NSDictionary dictionaryWithObjectsAndKeys:peerID, peerDisplayName, nil];
////                }
////                
////                if ([self.delegate respondsToSelector:@selector(peerController:connectedToPeer:)]) {
////                    [self.delegate peerController:self connectedToPeer:peerDisplayName];
////                }
////                break;
//            }
//                
//                
//            case GKPeerStateConnecting:
//                //                debugLog(@"Attempting to connect to peer: %@", peerDisplayName);
//                break;
//                
//                
//            case GKPeerStateDisconnected:
//            {
//                //                debugLog(@"Disconnected from peer: %@", peerDisplayName);
//                NSDictionary *existingPeerNames = self.connectedPeerNames;
//                if (existingPeerNames)
//                {
//                    if ([existingPeerNames valueForKey:peerName])
//                    {
//                        NSMutableDictionary *list = [[NSMutableDictionary alloc] initWithCapacity:existingPeerNames.count];
//                        [list addEntriesFromDictionary:existingPeerNames];
//                        [list setValue:nil forKey:peerName];
//                        self.connectedPeerNames = [NSDictionary dictionaryWithDictionary:list];
//                        [list release];
//                    }
//                }
////                [self.connectedPeerNames setValue:nil forKey:peerName];
//                
//                // begin storing the message cache to send back to the peer if connectivity is regained
//                //                debugLog(@"Creating a message cache for peer %@", [session displayNameForPeer:peerID]);
//                //                [self.messageCache setObject:[NSMutableArray arrayWithCapacity:1] forKey:[session displayNameForPeer:peerID]];
//                [session connectToPeer:peerID withTimeout:20];
//                break;
//            }
//                
//                
//            case GKPeerStateUnavailable:
//                //                debugLog(@"Peer is unavailable: %@", peerDisplayName);
//                break;
//                
//            default:
//                break;
//        }   
//    }
}



@end
