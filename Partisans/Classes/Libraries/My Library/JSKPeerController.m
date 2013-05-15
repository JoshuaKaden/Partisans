//
//  JSKPeerController.m
//  QuestPlayer
//
//  Created by Joshua Kaden on 4/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "JSKPeerController.h"

//#import "NSArray+SubArrays.h"
#import "JSKSystemMessage.h"


const NSUInteger PeerMessageSizeLimit = 10000;


@interface JSKPeerController ()

@property (nonatomic, strong) GKSession *gkSession;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, assign) BOOL isSending;
@property (readwrite, nonatomic, strong) NSString *myPeerID;
@property (nonatomic, strong) NSDictionary *connectedPeerNames;
@property (atomic, assign) BOOL isSlave;

- (BOOL)hasSessionStarted;
- (void)archiveAndSend:(NSObject <NSCoding> *)object toSessionPeerID:(NSString *)sessionPeerID;
- (void)handleCommandMessage:(JSKCommandMessage *)commandMessage fromSessionPeerID:(NSString *)sessionPeerID;
- (void)handleCommandResponse:(JSKCommandResponse *)commandResponse fromSessionPeerID:(NSString *)sessionPeerID;

@end


@implementation JSKPeerController

@synthesize gkSession = m_gkSession;
@synthesize queue = m_queue;
@synthesize isSending = m_isSending;
@synthesize myPeerID = m_myPeerID;
@synthesize delegate = m_delegate;
@synthesize connectedPeerNames = m_connectedPeerNames;
@synthesize peerID = m_peerID;
@synthesize isSlave = m_isSlave;



#pragma mark - Lifecycle


- (void)dealloc
{
    [m_gkSession setDelegate:nil];
    
    [m_gkSession release];
    [m_queue release];
    [m_myPeerID release];
    [m_connectedPeerNames release];
    [m_peerID release];
    
    [super dealloc];
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
    if (!self.connectedPeerNames)
    {
        self.connectedPeerNames = [NSDictionary dictionary];
    }
    
    NSString *sessionID = @"ThoroughlyRandomSessionIDForQuestPlayer";
    NSString *peerID = self.myPeerID;
    
    GKSession *gkSession = [[GKSession alloc] initWithSessionID:sessionID displayName:peerID sessionMode:GKSessionModePeer];
    
    [gkSession setAvailable:YES];
    [gkSession setDelegate:self];
    [gkSession setDataReceiveHandler:self withContext:gkSession];
    
    self.gkSession = gkSession;
    [gkSession release];
    
    //    debugLog(@"Initiating p2p session with ID: %@ as peer: %@", sessionID, peerID);
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
    
    self.connectedPeerNames = nil;
}


- (void)resetPeerID
{
    [self stopSession];
    [self setMyPeerID:nil];
}



#pragma mark - Sending


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
    [self broadcastCommandMessage:commandMessageType toPeerIDs:[self.connectedPeerNames allValues]];
}


- (void)archiveAndBroadcast:(NSObject <NSCoding> *)object
{
    for (NSString *peerID in [self.connectedPeerNames allValues])
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


- (void)sendCommandMessage:(JSKCommandMessage *)commandMessage {
    
    if (!commandMessage) {
        return;
    }
    
    [self archiveAndSend:commandMessage to:commandMessage.to];
}


- (void)sendCommandResponse:(JSKCommandResponse *)commandResponse
{
    if (!commandResponse)
    {
        return;
    }
    
    [self archiveAndSend:commandResponse to:commandResponse.to];
}



- (void)archiveAndSend:(NSObject <NSCoding> *)object toSessionPeerID:(NSString *)sessionPeerID
{
    NSString *peerID = sessionPeerID;
    
    // For now just send the data.
    // Worry about big messages later, if needs be.
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
    
//    debugLog(@"Will send a message of %d bytes to peer %@.", data.length, sessionPeerID);
//    debugLog(@"Sending: %@", object);
    //    debugLog(@"Sending raw: %@", data);
    
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
            
            
            [self.gkSession sendData:data toPeers:[NSArray arrayWithObject:peerID] withDataMode:GKSendDataUnreliable error:&sendError];
            
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
    NSArray *peerKeys = [self.connectedPeerNames allKeys];
    for (NSString *peerKey in peerKeys)
    {
        NSString *peerValue = [self.connectedPeerNames valueForKey:peerKey];
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

- (void)handleCommandResponse:(JSKCommandResponse *)commandResponse fromSessionPeerID:(NSString *)sessionPeerID
{
    // The "sessionPeerID" parameter is GameKit's ID.
    // We need to match it to our internal peer ID.
    NSString *peerID = [self.connectedPeerNames valueForKey:sessionPeerID];
    
    
    if ([self.delegate respondsToSelector:@selector(peerController:receivedCommandResponse:from:)])
    {
        [self.delegate peerController:self receivedCommandResponse:commandResponse from:peerID];
    }
    else
    {
        // Pass it on up the chain.
        if ([self.delegate respondsToSelector:@selector(peerController:receivedObject:from:)])
        {
            [self.delegate peerController:self receivedObject:commandResponse from:peerID];
        }
    }
}

- (void)handleCommandMessage:(JSKCommandMessage *)commandMessage fromSessionPeerID:(NSString *)sessionPeerID
{
    // The "sessionPeerID" parameter is GameKit's ID.
    // We need to match it to our internal peer ID.
    NSString *peerID = [self.connectedPeerNames valueForKey:sessionPeerID];
    
    // Special case for Identification messages:
    // Update our dictionary that maps our peer IDs to GameKit's.
    if (commandMessage.commandMessageType == JSKCommandMessageTypeIdentification)
    {
        if (!peerID)
        {
            peerID = commandMessage.from;
            
            NSDictionary *existingPeerNames = self.connectedPeerNames;
            
            if (existingPeerNames)
            {
                NSMutableDictionary *list = [[NSMutableDictionary alloc] initWithCapacity:existingPeerNames.count + 1];
                [list addEntriesFromDictionary:existingPeerNames];
                [list setValue:peerID forKey:sessionPeerID];
                self.connectedPeerNames = [NSDictionary dictionaryWithDictionary:list];
                [list release];
            }
            else
            {
                self.connectedPeerNames = [NSDictionary dictionaryWithObjectsAndKeys:peerID, sessionPeerID, nil];
            }
            
            if ([self.delegate respondsToSelector:@selector(peerController:connectedToPeer:)]) {
                [self.delegate peerController:self connectedToPeer:peerID];
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(peerController:receivedCommandMessage:from:)])
    {
        [self.delegate peerController:self receivedCommandMessage:commandMessage from:peerID];
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
    
    NSObject *statement = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//    debugLog(@"Received object from peer %@.\nThe object:\n%@", peer, statement);
    
    //    debugLog(@"Received raw: %@", data);
    
    
    // We're going to interpret them by class name.
    
    // Command Message
    if ([statement isKindOfClass:[JSKCommandMessage class]])
    {
        JSKCommandMessage *commandMessage = (JSKCommandMessage *)statement;
        [self handleCommandMessage:commandMessage fromSessionPeerID:peer];
    }
    else if ([statement isKindOfClass:[JSKCommandResponse class]])
    {
        JSKCommandResponse *commandResponse = (JSKCommandResponse *)statement;
        [self handleCommandResponse:commandResponse fromSessionPeerID:peer];
    }
    else
    {
        // Pass it on up the chain.
        if ([self.delegate respondsToSelector:@selector(peerController:receivedObject:from:)])
        {
            // The "peer" parameter is GameKit's ID.
            // We need to match it to our internal peer ID.
            NSString *peerID = [self.connectedPeerNames valueForKey:peer];
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
//            else if ([arrayItem isKindOfClass:[JSKCommandResponse class]])
//            {
//                JSKCommandResponse *commandResponse = (JSKCommandResponse *)arrayItem;
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
    
    // Create universally unique identifier (object)
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    
    // Get the string representation of CFUUID object.
    NSString *uuidStr = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuidObject);
    CFRelease(uuidObject);
    
    [self setMyPeerID:uuidStr];
    [uuidStr release];
    
    [[JSKSystemMessage sharedInstance] setMyPeerID:m_myPeerID];
    // Save the peer ID in user defaults.
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:m_myPeerID forKey:@"myPeerID"];
    
    return m_myPeerID;
}



#pragma mark - Private


- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                         change:(NSDictionary *)change context:(void *)context
{
    if (object == self.queue && [keyPath isEqualToString:@"operations"]) {
        if ([self.queue.operations count] == 0) {
            
            // The queue has completed.
            if ([self.delegate respondsToSelector:@selector(peerControllerQueueHasEmptied:)]) {
                [self.delegate peerControllerQueueHasEmptied:self];
            }
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object
                               change:change context:context];
    }
}




#pragma mark - GKSessionDelegate Methods


- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    //    debugLog(@"Received connection request from: %@",peerID);
    
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
    NSString *peerName = [self.connectedPeerNames valueForKey:peerID];
//    NSString *peerDisplayName = peerID;
//    NSString *peerDisplayName = [session displayNameForPeer:peerID];
    
    if (peerID) // && peerName)
    {
        //        debugLog(@"Peer %@ state changed to: %i", peerDisplayName, state);
        
        
        //        NSDictionary *existingPeerNames = nil;
        //        if (self.connectedPeerNames) {
        //            existingPeerNames = [NSDictionary dictionaryWithDictionary:self.connectedPeerNames];
        //        }
        
        
        
        
        //        if (!self.connectedPeerNames) {
        //            NSMutableDictionary *connectedPeerNames = [[NSMutableDictionary alloc] initWithCapacity:10];
        //            self.connectedPeerNames = connectedPeerNames;
        //            [connectedPeerNames release];
        //        }
        
        switch (state) {
                
                
            case GKPeerStateAvailable:
                [session connectToPeer:peerID withTimeout:20];
                break;
                
                
            case GKPeerStateConnected:
            {
//                debugLog(@"Connected to peer:%@ named:%@", peerID, peerDisplayName);
                
                // Once we connect to a peer, we automatically send them our name.
                // They will appreciate this, as it enables us to address each other, using our own names.
                JSKCommandMessage *msg = [[JSKCommandMessage alloc] initWithType:JSKCommandMessageTypeIdentification to:peerName from:self.peerID];
                [self archiveAndSend:msg toSessionPeerID:peerID];
                [msg release];
                break;
                
//                NSDictionary *existingPeerNames = self.connectedPeerNames;
//                
//                if (existingPeerNames)
//                {
//                    if (![existingPeerNames valueForKey:peerDisplayName])
//                    {
//                        NSMutableDictionary *list = [[NSMutableDictionary alloc] initWithCapacity:existingPeerNames.count + 1];
//                        [list addEntriesFromDictionary:existingPeerNames];
//                        [list setValue:peerID forKey:peerDisplayName];
//                        self.connectedPeerNames = [NSDictionary dictionaryWithDictionary:list];
//                        [list release];
//                    }
//                }
//                else
//                {
//                    self.connectedPeerNames = [NSDictionary dictionaryWithObjectsAndKeys:peerID, peerDisplayName, nil];
//                }
//                
//                if ([self.delegate respondsToSelector:@selector(peerController:connectedToPeer:)]) {
//                    [self.delegate peerController:self connectedToPeer:peerDisplayName];
//                }
//                break;
            }
                
                
            case GKPeerStateConnecting:
                //                debugLog(@"Attempting to connect to peer: %@", peerDisplayName);
                break;
                
                
            case GKPeerStateDisconnected:
            {
                //                debugLog(@"Disconnected from peer: %@", peerDisplayName);
                NSDictionary *existingPeerNames = self.connectedPeerNames;
                if (existingPeerNames)
                {
                    if ([existingPeerNames valueForKey:peerName])
                    {
                        NSMutableDictionary *list = [[NSMutableDictionary alloc] initWithCapacity:existingPeerNames.count];
                        [list addEntriesFromDictionary:existingPeerNames];
                        [list setValue:nil forKey:peerName];
                        self.connectedPeerNames = [NSDictionary dictionaryWithDictionary:list];
                        [list release];
                    }
                }
//                [self.connectedPeerNames setValue:nil forKey:peerName];
                
                // begin storing the message cache to send back to the peer if connectivity is regained
                //                debugLog(@"Creating a message cache for peer %@", [session displayNameForPeer:peerID]);
                //                [self.messageCache setObject:[NSMutableArray arrayWithCapacity:1] forKey:[session displayNameForPeer:peerID]];
                [session connectToPeer:peerID withTimeout:20];
                break;
            }
                
                
            case GKPeerStateUnavailable:
                //                debugLog(@"Peer is unavailable: %@", peerDisplayName);
                break;
                
            default:
                break;
        }   
    }
}



@end
