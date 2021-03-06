//
//  JSKCommandMessage.m
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

#import "JSKCommandMessage.h"

@implementation JSKCommandMessage

@synthesize commandMessageType = m_commandMessageType;
@synthesize to = m_to;
@synthesize from = m_from;
@synthesize responseKey = m_responseKey;




- (id)initWithType:(JSKCommandMessageType)commandMessageType to:(NSString *)to from:(NSString *)from
{
    self = [super init];
    if (self)
    {
        self.commandMessageType = commandMessageType;
        self.to = to;
        self.from = from;
    }
    return self;
}


- (NSString *)description
{
    NSString *toString = self.to;
    if (!toString)
    {
        toString = @"";
    }
    
    NSString *fromString = self.from;
    if (!fromString)
    {
        fromString = @"";
    }
    
    NSString *typeString = self.commandMessageTypeName;
    if (!typeString)
    {
        typeString = @"";
    }
    
    NSString *responseKeyString = self.responseKey;
    if (!responseKeyString)
    {
        responseKeyString = @"";
    }
    
    NSDictionary *descDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"JSKCommandMessage", @"Class",
                              [NSNumber numberWithInt:self.commandMessageType].description, @"commandMessageType",
                              typeString, @"commandMessageTypeName",
                              fromString, @"from",
                              toString, @"to",
                              responseKeyString, @"responseKey", nil];
    return descDict.description;
}
//- (NSString *)description
//{
//    NSDictionary *descDict = [NSDictionary dictionaryWithObjectsAndKeys:
//                              [NSNumber numberWithInt:self.commandMessageType].description, @"commandMessageType",
//                              self.to, @"toPeerName",
//                              self.from, @"replyTo", nil];
//    return descDict.description;
//}


- (NSString *)commandMessageTypeName
{
    return [JSKCommandMessage messageTypeName:self.commandMessageType];
}




+ (NSString *)messageTypeName:(JSKCommandMessageType)messageType
{
    NSString *name = nil;
    
    switch (messageType)
    {
        case JSKCommandMessageTypeAcknowledge:
            name = @"Acknowledge";
            break;
            
        case JSKCommandMessageTypeFail:
            name = @"Fail";
            break;
            
        case JSKCommandMessageTypeDidFinish:
            name = @"DidFinish";
            break;
            
        case JSKCommandMessageTypeGetDigest:
            name = @"GetDigest";
            break;
            
        case JSKCommandMessageTypeGetInfo:
            name = @"GetInfo";
            break;
            
        case JSKCommandMessageTypeGetModifiedDate:
            name = @"GetModifiedDate";
            break;
            
        case JSKCommandMessageTypeGetLocation:
            name = @"GetLocation";
            break;
            
        case JSKCommandMessageTypeIdentification:
            name = @"Identification";
            break;
            
        case JSKCommandMessageTypeJoinGame:
            name = @"JoinGame";
            break;

        case JSKCommandMessageTypeLeaveGame:
            name = @"LeaveGame";
            break;
            
        case JSKCommandMessageTypePause:
            name = @"Pause";
            break;
            
        case JSKCommandMessageTypeResume:
            name = @"Resume";
            break;
            
        case JSKCommandMessageTypeStart:
            name = @"Start";
            break;
            
        case JSKCommandMessageTypeStop:
            name = @"Stop";
            break;

        case JSKCommandMessageTypeSucceed:
            name = @"Succeed";
            break;
            
        case JSKCommandMessageTypeUnknown:
            name = @"Unknown";
            break;
            
        case JSKCommandMessageType_maxValue:
            break;
    }
    
    return name;
}




#pragma mark - NSCoder methods


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:self.commandMessageType forKey:@"commandMessageType"];
    [aCoder encodeObject:self.to forKey:@"toPeerName"];
    [aCoder encodeObject:self.from forKey:@"replyTo"];
    [aCoder encodeObject:self.responseKey forKey:@"responseKey"];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self)
    {
        self.commandMessageType = [aDecoder decodeIntForKey:@"commandMessageType"];
        self.to = [aDecoder decodeObjectForKey:@"toPeerName"];
        self.from = [aDecoder decodeObjectForKey:@"replyTo"];
        self.responseKey = [aDecoder decodeObjectForKey:@"responseKey"];
    }
    
    return self;
}


@end
