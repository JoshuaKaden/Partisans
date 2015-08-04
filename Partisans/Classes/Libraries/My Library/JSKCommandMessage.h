//
//  JSKCommandMessage.h
//  Partisans
//
//  Created by Joshua Kaden on 4/19/13.
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
#import "JSKCommandMessageProtocol.h"


typedef enum
{
    JSKCommandMessageTypeAcknowledge,
    JSKCommandMessageTypeDidFinish,
    JSKCommandMessageTypeFail,
    JSKCommandMessageTypeGetDigest,
    JSKCommandMessageTypeGetInfo,
    JSKCommandMessageTypeGetLocation,
    JSKCommandMessageTypeGetModifiedDate,
    JSKCommandMessageTypeIdentification,
    JSKCommandMessageTypeJoinGame,
    JSKCommandMessageTypeLeaveGame,
    JSKCommandMessageTypePause,
    JSKCommandMessageTypeResume,
    JSKCommandMessageTypeStart,
    JSKCommandMessageTypeStop,
    JSKCommandMessageTypeSucceed,
    JSKCommandMessageTypeUnknown,
    JSKCommandMessageType_maxValue
} JSKCommandMessageType;


// Just a note that I should make an effort to keep this class as light as possible.
// My intent here is a small, generic object that can provide punctuation for other
// objects when sending them to and fro between devices.

@interface JSKCommandMessage : NSObject <NSCoding, JSKCommandMessageProtocol>

@property (nonatomic, assign) JSKCommandMessageType commandMessageType;
@property (nonatomic, strong) NSString *to;
@property (nonatomic, strong) NSString *from;
@property (nonatomic, readonly) NSString *commandMessageTypeName;
@property (nonatomic, strong) NSString *responseKey;

- (id)initWithType:(JSKCommandMessageType)commandMessageType to:(NSString *)to from:(NSString *)from;

+ (NSString *)messageTypeName:(JSKCommandMessageType)messageType;

@end
