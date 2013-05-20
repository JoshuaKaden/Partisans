//
//  JSKCommandMessage.h
//  Partisans
//
//  Created by Joshua Kaden on 4/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum
{
    JSKCommandMessageTypeDidFinish,
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
    JSKCommandMessageTypeUnknown,
    JSKCommandMessageType_maxValue
} JSKCommandMessageType;


// Just a note that I should make an effort to keep this class as light as possible.
// My intent here is a small, generic object that can provide punctuation for other
// objects when sending them to and fro between devices.

@interface JSKCommandMessage : NSObject <NSCoding>

@property (nonatomic, assign) JSKCommandMessageType commandMessageType;
@property (nonatomic, strong) NSString *to;
@property (nonatomic, strong) NSString *from;
@property (readonly, nonatomic) NSString *commandMessageTypeName;

- (id)initWithType:(JSKCommandMessageType)commandMessageType to:(NSString *)to from:(NSString *)from;

+ (NSString *)messageTypeName:(JSKCommandMessageType)messageType;

@end
