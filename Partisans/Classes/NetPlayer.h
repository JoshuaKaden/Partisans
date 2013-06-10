//
//  NetPlayer.h
//  Partisans
//
//  Created by Joshua Kaden on 6/7/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSKCommandMessage.h"

@class JSKCommandParcel;
@class NetPlayer;


@protocol NetPlayerDelegate <NSObject>

- (NSString *)netPlayerPeerID:(NetPlayer *)netPlayer;
- (void)netPlayer:(NetPlayer *)netPlayer receivedCommandMessage:(JSKCommandMessage *)commandMessage;
- (void)netPlayer:(NetPlayer *)netPlayer receivedCommandParcel:(JSKCommandParcel *)commandParcel;
- (void)netPlayer:(NetPlayer *)netPlayer receivedCommandParcel:(JSKCommandParcel *)commandParcel respondingTo:(NSObject <NSCoding> *)inResponseTo;
- (void)netPlayer:(NetPlayer *)netPlayer terminated:(NSString *)reason;
- (void)netPlayerDidResolveAddress:(NetPlayer *)netPlayer;

@end


@interface NetPlayer : NSObject

@property (nonatomic, strong) id <NetPlayerDelegate> delegate;
@property (readonly) BOOL hasStarted;

- (id)initWithHost:(NSString *)host andPort:(int)port;
- (id)initWithNetService:(NSNetService *)netService;

- (BOOL)start;
- (void)stop;

- (void)sendCommandMessage:(JSKCommandMessage *)commandMessage;
- (void)sendCommandMessage:(JSKCommandMessage *)commandMessage shouldAwaitResponse:(BOOL)shouldAwaitResponse;
- (void)sendCommandParcel:(JSKCommandParcel *)commandParcel;
- (void)sendCommandParcel:(JSKCommandParcel *)commandParcel shouldAwaitResponse:(BOOL)shouldAwaitResponse;

@end
