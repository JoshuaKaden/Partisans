//
//  NetHost.h
//  Partisans
//
//  Created by Joshua Kaden on 6/6/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConnectionDelegate.h"
#import "JSKCommandMessage.h"
#import "Server.h"
#import "ServerDelegate.h"

@class JSKCommandParcel;
@class NetHost;


@protocol NetHostDelegate <NSObject>

- (void)netHost:(NetHost *)netHost receivedCommandMessage:(JSKCommandMessage *)commandMessage;
- (void)netHost:(NetHost *)netHost receivedCommandParcel:(JSKCommandParcel *)commandParcel;
- (void)netHost:(NetHost *)netHost receivedCommandParcel:(JSKCommandParcel *)commandParcel respondingTo:(NSObject <NSCoding> *)inResponseTo;
- (void)netHost:(NetHost *)netHost receivedObject:(NSObject <NSCoding> *)object from:peerID;
- (void)netHost:(NetHost *)netHost terminated:(NSString *)reason;

@end


@interface NetHost : NSObject <ServerDelegate, ConnectionDelegate>

@property (nonatomic, strong) id <NetHostDelegate> delegate;

- (BOOL)start;
- (void)stop;

- (void)sendCommandMessage:(JSKCommandMessage *)commandMessage;
- (void)sendCommandMessage:(JSKCommandMessage *)commandMessage shouldAwaitResponse:(BOOL)shouldAwaitResponse;
- (void)sendCommandParcel:(JSKCommandParcel *)commandParcel;
- (void)sendCommandParcel:(JSKCommandParcel *)commandParcel shouldAwaitResponse:(BOOL)shouldAwaitResponse;
- (void)sendObject:(NSObject <NSCoding> *)object to:(NSString *)peerID;

// For this to work, please ensure that the supplied "object" has an NSString "responseKey" attribute.
- (void)sendObject:(NSObject <NSCoding> *)object to:(NSString *)peerID shouldAwaitResponse:(BOOL)shouldAwaitResponse;

- (void)broadcastCommandMessageType:(JSKCommandMessageType)commandMessageType;

@end
