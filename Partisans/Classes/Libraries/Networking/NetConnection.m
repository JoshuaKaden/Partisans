//
//  Connection.m
//  Chatty
//
//  Copyright (c) 2009 Peter Bakhyryev <peter@byteclub.com>, ByteClub LLC
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.

#import "NetConnection.h"
#import "SystemMessage.h"


// Declare C callback functions
void readStreamEventHandler(CFReadStreamRef stream, CFStreamEventType eventType, void *info);
void writeStreamEventHandler(CFWriteStreamRef stream, CFStreamEventType eventType, void *info);


// Private properties and methods
@interface NetConnection ()

// Properties
@property (nonatomic, assign) int port;
@property (nonatomic, assign) CFSocketNativeHandle connectedSocketHandle;
@property (nonatomic, retain) NSNetService *netService;
@property (nonatomic, strong) NSMutableData *outgoingDataBuffer;
@property (nonatomic, strong) NSMutableData *incomingDataBuffer;
@property (nonatomic, assign) CFReadStreamRef readStream;
@property (nonatomic, assign) BOOL isReadStreamOpen;
@property (nonatomic, assign) int packetBodySize;
@property (nonatomic, assign) CFWriteStreamRef writeStream;
@property (nonatomic, assign) BOOL isWriteStreamOpen;

// Initialize
- (void)clean;

// Further setup streams created by one of the 'init' methods
- (BOOL)setupSocketStreamsRead:(CFReadStreamRef)readStream write:(CFWriteStreamRef)writeStream;

// Stream event handlers
- (void)readStreamHandleEvent:(CFStreamEventType)event;
- (void)writeStreamHandleEvent:(CFStreamEventType)event;

// Read all available bytes from the read stream into buffer and try to extract packets
- (void)readFromStreamIntoIncomingBuffer;

// Write whatever data we have in the buffer, as much as stream can handle
- (void)writeOutgoingBufferToStream;

@end


@implementation NetConnection

@synthesize delegate = m_delegate;
@synthesize host = m_host;
@synthesize port = m_port;
@synthesize connectedSocketHandle = m_connectedSocketHandle;
@synthesize netService = m_netService;
@synthesize outgoingDataBuffer = m_outgoingDataBuffer;
@synthesize incomingDataBuffer = m_incomingDataBuffer;
@synthesize peerID = m_peerID;
@synthesize readStream = m_readStream;
@synthesize isReadStreamOpen = m_isReadStreamOpen;
@synthesize packetBodySize = m_packetBodySize;
@synthesize writeStream = m_writeStream;
@synthesize isWriteStreamOpen = m_isWriteStreamOpen;


// Initialize, empty
- (void)clean
{
    self.readStream = nil;
    self.isReadStreamOpen = NO;
    
    self.writeStream = nil;
    self.isWriteStreamOpen = NO;
    
    self.incomingDataBuffer = nil;
    self.outgoingDataBuffer = nil;
    
    self.netService = nil;
    self.host = nil;
    self.connectedSocketHandle = -1;
    self.packetBodySize = -1;
}


// cleanup
- (void)dealloc
{
    self.netService = nil;
    self.host = nil;
    self.delegate = nil;
    [m_outgoingDataBuffer release];
    [m_incomingDataBuffer release];
    [m_peerID release];
    
    [super dealloc];
}


// Initialize and store connection information until 'connect' is called
- (id)initWithHostAddress:(NSString*)host andPort:(int)port
{
    [self clean];
    
    self.host = host;
    self.port = port;
    return self;
}


// Initialize using a native socket handle, assuming connection is open
- (id)initWithNativeSocketHandle:(CFSocketNativeHandle)nativeSocketHandle
{
    [self clean];
    
    self.connectedSocketHandle = nativeSocketHandle;
    return self;
}


// Initialize using an instance of NSNetService
- (id)initWithNetService:(NSNetService*)netService
{
    [self clean];
    
    // Has it been resolved?
    if ( netService.hostName != nil ) {
        return [self initWithHostAddress:netService.hostName andPort:netService.port];
    }
    
    self.netService = netService;
    return self;
}


// Connect using whatever connection info that was passed during initialization
- (BOOL)connect
{
    CFReadStreamRef readStream = self.readStream;
    CFWriteStreamRef writeStream = self.writeStream;
    
    if (self.host)
    {
        // Bind read/write streams to a new socket
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (CFStringRef)self.host,
                                           self.port, &readStream, &writeStream);
        
        // Do the rest
        return [self setupSocketStreamsRead:readStream write:writeStream];
    }
    else if ( self.connectedSocketHandle != -1 )
    {
        // Bind read/write streams to a socket represented by a native socket handle
        CFStreamCreatePairWithSocket(kCFAllocatorDefault, self.connectedSocketHandle,
                                     &readStream, &writeStream);
        
        // Do the rest
        return [self setupSocketStreamsRead:readStream write:writeStream];
    }
    else if (self.netService)
    {
        // Still need to resolve?
        if ( self.netService.hostName != nil )
        {
            CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                               (CFStringRef)self.netService.hostName, self.netService.port, &readStream, &writeStream);
            return [self setupSocketStreamsRead:readStream write:writeStream];
        }
        
        // Start resolving
        self.netService.delegate = (id<NSNetServiceDelegate>)self;
        [self.netService resolveWithTimeout:5.0];
        return YES;
    }
    
    // Nothing was passed, connection is not possible
    return NO;
}


// Further setup socket streams that were created by one of our 'init' methods
- (BOOL)setupSocketStreamsRead:(CFReadStreamRef)readStream write:(CFWriteStreamRef)writeStream
{
    // Make sure streams were created correctly
    if ( readStream == nil || writeStream == nil ) {
        [self close];
        return NO;
    }
    
    self.readStream = readStream;
    self.writeStream = writeStream;
    
    // Create buffers
    NSMutableData *incomingDataBuffer = [[NSMutableData alloc] init];
    self.incomingDataBuffer = incomingDataBuffer;
    [incomingDataBuffer release];
    NSMutableData *outgoingDataBuffer = [[NSMutableData alloc] init];
    self.outgoingDataBuffer = outgoingDataBuffer;
    [outgoingDataBuffer release];
    
    // Indicate that we want socket to be closed whenever streams are closed
    CFReadStreamSetProperty(self.readStream, kCFStreamPropertyShouldCloseNativeSocket,
                            kCFBooleanTrue);
    CFWriteStreamSetProperty(self.writeStream, kCFStreamPropertyShouldCloseNativeSocket,
                             kCFBooleanTrue);
    
    // We will be handling the following stream events
    CFOptionFlags registeredEvents = kCFStreamEventOpenCompleted |
    kCFStreamEventHasBytesAvailable | kCFStreamEventCanAcceptBytes |
    kCFStreamEventEndEncountered | kCFStreamEventErrorOccurred;
    
    // Setup stream context - reference to 'self' will be passed to stream event handling callbacks
    CFStreamClientContext ctx = {0, self, NULL, NULL, NULL};
    
    // Specify callbacks that will be handling stream events
    CFReadStreamSetClient(self.readStream, registeredEvents, readStreamEventHandler, &ctx);
    CFWriteStreamSetClient(self.writeStream, registeredEvents, writeStreamEventHandler, &ctx);
    
    // Schedule streams with current run loop
    CFReadStreamScheduleWithRunLoop(self.readStream, CFRunLoopGetCurrent(),
                                    kCFRunLoopCommonModes);
    CFWriteStreamScheduleWithRunLoop(self.writeStream, CFRunLoopGetCurrent(),
                                     kCFRunLoopCommonModes);
    
    // Open both streams
    if ( ! CFReadStreamOpen(self.readStream) || ! CFWriteStreamOpen(self.writeStream)) {
        [self close];
        return NO;
    }
    
    return YES;
}


// Close connection
- (void)close
{
    // Cleanup read stream
    if ( self.readStream != nil ) {
        CFReadStreamUnscheduleFromRunLoop(self.readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        CFReadStreamClose(self.readStream);
//        CFRelease(self.readStream);
        self.readStream = NULL;
    }
    
    // Cleanup write stream
    if ( self.writeStream != nil ) {
        CFWriteStreamUnscheduleFromRunLoop(self.writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        CFWriteStreamClose(self.writeStream);
//        CFRelease(self.writeStream);
        self.writeStream = NULL;
    }
    
    // Cleanup buffers
//    [m_incomingDataBuffer release];
    self.incomingDataBuffer = nil;
    
    self.outgoingDataBuffer = nil;
    
    // Stop net service?
    if ( self.netService != nil ) {
        [self.netService stop];
        self.netService = nil;
    }
    
    // Reset all other variables
    [self clean];
}


// Send network message
- (void)sendNetworkPacket:(NSObject <NSCoding> *)packet
{
    // Encode packet
    NSData* rawPacket = [NSKeyedArchiver archivedDataWithRootObject:packet];
    
    // Write header: lengh of raw packet
    int packetLength = [rawPacket length];
    [self.outgoingDataBuffer appendBytes:&packetLength length:sizeof(int)];
    
    // Write body: encoded NSDictionary
    [self.outgoingDataBuffer appendData:rawPacket];
    
//    debugLog(@"outgoingDataBuffer %@", self.outgoingDataBuffer);
    
    // Try to write to stream
    [self writeOutgoingBufferToStream];
}


#pragma mark Read stream methods

// Dispatch readStream events
void readStreamEventHandler(CFReadStreamRef stream, CFStreamEventType eventType,
                            void *info) {
    dispatch_async(dispatch_get_main_queue(), ^(void)
    {
        NetConnection* connection = (NetConnection*)info;
        [connection readStreamHandleEvent:eventType];
    });
}


// Handle events from the read stream
- (void)readStreamHandleEvent:(CFStreamEventType)event
{
    // Stream successfully opened
    if ( event == kCFStreamEventOpenCompleted ) {
        self.isReadStreamOpen = YES;
    }
    // New data has arrived
    else if ( event == kCFStreamEventHasBytesAvailable ) {
        // Read as many bytes from the stream as possible and try to extract meaningful packets
        [self readFromStreamIntoIncomingBuffer];
    }
    // Connection has been terminated or error encountered (we treat them the same way)
    else if ( event == kCFStreamEventEndEncountered || event == kCFStreamEventErrorOccurred ) {
        // Clean everything up
        [self close];
        
        // If we haven't connected yet then our connection attempt has failed
        if ( !self.isReadStreamOpen || !self.isWriteStreamOpen ) {
            [self.delegate connectionAttemptFailed:self];
        }
        else {
            [self.delegate connectionTerminated:self];
        }
    }
}


// Read as many bytes from the stream as possible and try to extract meaningful packets
- (void)readFromStreamIntoIncomingBuffer
{
    // Temporary buffer to read data into
    UInt8 buf[1024];
    
    // Try reading while there is data
    while( CFReadStreamHasBytesAvailable(self.readStream) ) {
        CFIndex len = CFReadStreamRead(self.readStream, buf, sizeof(buf));
        if ( len <= 0 ) {
            // Either stream was closed or error occurred. Close everything up and treat this as "connection terminated"
            [self close];
            [self.delegate connectionTerminated:self];
            return;
        }
        
        [self.incomingDataBuffer appendBytes:buf length:len];
    }
    
    // Try to extract packets from the buffer.
    //
    // Protocol: header + body
    //  header: an integer that indicates length of the body
    //  body: bytes that represent encoded NSDictionary
    
    // We might have more than one message in the buffer - that's why we'll be reading it inside the while loop
    while( YES )
    {
        int packetBodySize = self.packetBodySize;
        // Did we read the header yet?
        if ( packetBodySize == -1 ) {
            // Do we have enough bytes in the buffer to read the header?
            if ( [self.incomingDataBuffer length] >= sizeof(int) ) {
                // extract length
                memcpy(&packetBodySize, [self.incomingDataBuffer bytes], sizeof(int));
                self.packetBodySize = packetBodySize;
                
                // remove that chunk from buffer
                NSRange rangeToDelete = {0, sizeof(int)};
                [self.incomingDataBuffer replaceBytesInRange:rangeToDelete withBytes:NULL length:0];
            }
            else {
                // We don't have enough yet. Will wait for more data.
                break;
            }
        }
        
        // We should now have the header. Time to extract the body.
        if ( [self.incomingDataBuffer length] >= packetBodySize ) {
            // We now have enough data to extract a meaningful packet.
            NSData* raw = [NSData dataWithBytes:[self.incomingDataBuffer bytes] length:packetBodySize];
            NSObject <NSCoding> *packet = [NSKeyedUnarchiver unarchiveObjectWithData:raw];
            
            // Tell our delegate about it
            [self.delegate receivedNetworkPacket:packet viaConnection:self];
            
            // Remove that chunk from buffer
            NSRange rangeToDelete = {0, packetBodySize};
            [self.incomingDataBuffer replaceBytesInRange:rangeToDelete withBytes:NULL length:0];
            
            // We have processed the packet. Resetting the state.
            packetBodySize = -1;
            self.packetBodySize = packetBodySize;
        }
        else {
            // Not enough data yet. Will wait.
            break;
        }
    }
}


#pragma mark Write stream methods

// Dispatch writeStream event handling
void writeStreamEventHandler(CFWriteStreamRef stream, CFStreamEventType eventType, void *info)
{
    dispatch_async(dispatch_get_main_queue(), ^(void)
    {
        NetConnection* connection = (NetConnection*)info;
        [connection writeStreamHandleEvent:eventType];
    });
}


// Handle events from the write stream
- (void)writeStreamHandleEvent:(CFStreamEventType)event
{
    // Stream successfully opened
    if ( event == kCFStreamEventOpenCompleted ) {
        self.isWriteStreamOpen = YES;
    }
    // Stream has space for more data to be written
    else if ( event == kCFStreamEventCanAcceptBytes ) {
        // Write whatever data we have, as much as stream can handle
        [self writeOutgoingBufferToStream];
    }
    // Connection has been terminated or error encountered (we treat them the same way)
    else if ( event == kCFStreamEventEndEncountered || event == kCFStreamEventErrorOccurred ) {
        // Clean everything up
        [self close];
        
        // If we haven't connected yet then our connection attempt has failed
        if ( !self.isReadStreamOpen || !self.isWriteStreamOpen ) {
            [self.delegate connectionAttemptFailed:self];
        }
        else {
            [self.delegate connectionTerminated:self];
        }
    }
}


// Write whatever data we have, as much of it as stream can handle
- (void)writeOutgoingBufferToStream
{
    // Is connection open?
    if ( !self.isReadStreamOpen || !self.isWriteStreamOpen ) {
        // No, wait until everything is operational before pushing data through
        return;
    }
    
    // Do we have anything to write?
    if ( [self.outgoingDataBuffer length] == 0 ) {
        return;
    }
    
    // Can stream take any data in?
    if ( !CFWriteStreamCanAcceptBytes(self.writeStream) ) {
        return;
    }
    
    // Write as much as we can
    CFIndex writtenBytes = CFWriteStreamWrite(self.writeStream, [self.outgoingDataBuffer bytes], [self.outgoingDataBuffer length]);
    
    if ( writtenBytes == -1 )
    {
        // Error occurred. Close everything up.
        [self close];
        [self.delegate connectionTerminated:self];
        return;
    }
    
    NSRange range = {0, writtenBytes};
    [self.outgoingDataBuffer replaceBytesInRange:range withBytes:NULL length:0];
}


#pragma mark -
#pragma mark NSNetService Delegate Method Implementations

// Called if we weren't able to resolve net service
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    if ( sender != self.netService )
    {
        return;
    }
    
    // Close everything and tell delegate that we have failed
    [self.delegate connectionAttemptFailed:self];
    [self close];
}


// Called when net service has been successfully resolved
- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    if ( sender != self.netService ) {
        return;
    }
    
    // Save connection info
    self.host = self.netService.hostName;
    self.port = self.netService.port;
    
    // Don't need the service anymore
    self.netService = nil;
    
    // Connect!
    if ( ![self connect] ) {
        [self.delegate connectionAttemptFailed:self];
        [self close];
    }
    else
    {
        [self.delegate netServiceDidResolveAddress:self];
    }
}

@end
