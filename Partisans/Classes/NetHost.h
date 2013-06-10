//
//  NetHost.h
//  Partisans
//
//  Created by Joshua Kaden on 6/6/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSKCommandMessage.h"

@class JSKCommandParcel;
@class NetHost;


@protocol NetHostDelegate <NSObject>

- (NSString *)netHostPeerID:(NetHost *)netHost;
- (void)netHost:(NetHost *)netHost receivedCommandMessage:(JSKCommandMessage *)commandMessage;
- (void)netHost:(NetHost *)netHost receivedCommandParcel:(JSKCommandParcel *)commandParcel;
- (void)netHost:(NetHost *)netHost receivedCommandParcel:(JSKCommandParcel *)commandParcel respondingTo:(NSObject <NSCoding> *)inResponseTo;
- (void)netHost:(NetHost *)netHost terminated:(NSString *)reason;

@end


@interface NetHost : NSObject

@property (nonatomic, strong) id <NetHostDelegate> delegate;
@property (readonly) BOOL hasStarted;

- (BOOL)start;
- (void)stop;

- (void)sendCommandMessage:(JSKCommandMessage *)commandMessage;
- (void)sendCommandMessage:(JSKCommandMessage *)commandMessage shouldAwaitResponse:(BOOL)shouldAwaitResponse;
- (void)sendCommandParcel:(JSKCommandParcel *)commandParcel;
- (void)sendCommandParcel:(JSKCommandParcel *)commandParcel shouldAwaitResponse:(BOOL)shouldAwaitResponse;
- (void)broadcastCommandMessageType:(JSKCommandMessageType)commandMessageType;

@end
