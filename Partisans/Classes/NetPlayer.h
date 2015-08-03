//
//  NetPlayer.h
//  Partisans
//
//  Created by Joshua Kaden on 6/7/13.
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

#import <Foundation/Foundation.h>
#import "JSKCommandMessage.h"

@class JSKCommandParcel;
@class NetPlayer;


@protocol NetPlayerDelegate <NSObject>

- (NSString *)netPlayerPeerID:(NetPlayer *)netPlayer;
- (NSDate *)netPlayerModifiedDate:(NetPlayer *)netPlayer;
- (void)netPlayer:(NetPlayer *)netPlayer receivedCommandMessage:(JSKCommandMessage *)commandMessage;
- (void)netPlayer:(NetPlayer *)netPlayer receivedCommandParcel:(JSKCommandParcel *)commandParcel;
- (void)netPlayer:(NetPlayer *)netPlayer receivedCommandParcel:(JSKCommandParcel *)commandParcel respondingTo:(NSObject <NSCoding> *)inResponseTo;
- (void)netPlayer:(NetPlayer *)netPlayer terminated:(NSString *)reason;
- (void)netPlayerDidResolveAddress:(NetPlayer *)netPlayer;

@end


@interface NetPlayer : NSObject

@property (nonatomic, weak) id <NetPlayerDelegate> delegate;
@property (readonly) BOOL hasStarted;
@property (nonatomic, readonly) NSString *hostPeerID;

- (id)initWithHost:(NSString *)host andPort:(int)port;
- (id)initWithNetService:(NSNetService *)netService;

- (BOOL)start;
- (void)stop;

- (void)sendCommandMessage:(JSKCommandMessage *)commandMessage;
- (void)sendCommandMessage:(JSKCommandMessage *)commandMessage shouldAwaitResponse:(BOOL)shouldAwaitResponse;
- (void)sendCommandParcel:(JSKCommandParcel *)commandParcel;
- (void)sendCommandParcel:(JSKCommandParcel *)commandParcel shouldAwaitResponse:(BOOL)shouldAwaitResponse;

@end
