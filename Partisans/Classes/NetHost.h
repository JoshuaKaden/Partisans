//
//  NetHost.h
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
- (void)broadcastCommandParcel:(JSKCommandParcel *)commandParcel;

@end
