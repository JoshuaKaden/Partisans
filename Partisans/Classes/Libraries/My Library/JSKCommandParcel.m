//
//  JSKCommandParcel.m
//  Partisans
//
//  Created by Joshua Kaden on 5/10/13.
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

#import "JSKCommandParcel.h"

@implementation JSKCommandParcel

@synthesize commandParcelType = m_commandParcelType;
@synthesize to = m_to;
@synthesize from = m_from;
@synthesize responseKey = m_responseKey;
@synthesize object = m_object;




- (id)initWithType:(JSKCommandParcelType)commandParcelType
                to:(NSString *)to
              from:(NSString *)from
            object:(id<NSCoding>)object
       responseKey:(NSString *)responseKey
{
    self = [super init];
    if (self)
    {
        self.commandParcelType = commandParcelType;
        self.to = to;
        self.from = from;
        [self setObject:(NSObject <NSCoding> *)object];
        self.responseKey = responseKey;
    }
    return self;
}

- (id)initWithType:(JSKCommandParcelType)commandParcelType
                to:(NSString *)to
              from:(NSString *)from
            object:(id<NSCoding>)object
{
    return [self initWithType:commandParcelType to:to from:from object:object responseKey:nil];
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
    
    NSString *typeString = self.commandParcelTypeName;
    if (!typeString)
    {
        typeString = @"";
    }
    
    NSString *responseKeyString = self.responseKey;
    if (!responseKeyString)
    {
        responseKeyString = @"";
    }
    
    NSString *objectString = self.object.description;
    if (!objectString)
    {
        objectString = @"";
    }
    
    NSDictionary *descDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"JSKCommandParcel", @"Class",
                              [NSNumber numberWithInt:self.commandParcelType].description, @"commandParcelType",
                              typeString, @"commandParcelTypeName",
                              fromString, @"from",
                              toString, @"to",
                              responseKeyString, @"responseKey",
                              objectString, @"object", nil];
    return descDict.description;
}


- (NSString *)commandParcelTypeName
{
    return [JSKCommandParcel responseTypeName:self.commandParcelType];
}




+ (NSString *)responseTypeName:(JSKCommandParcelType)responseType
{
    NSString *name = nil;
    
    switch (responseType)
    {
        case JSKCommandParcelTypeDigest:
            name = @"Digest";
            break;
            
        case JSKCommandParcelTypeModifiedDate:
            name = @"ModifiedDate";
            break;
            
        case JSKCommandParcelTypeResponse:
            name = @"Response";
            break;
            
        case JSKCommandParcelTypeUnknown:
            name = @"Unknown";
            break;
            
        case JSKCommandParcelTypeUpdate:
            name = @"Update";
            break;
            
        case JSKCommandParcelType_maxValue:
            break;
    }
    
    return name;
}




#pragma mark - NSCoder methods


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:self.commandParcelType forKey:@"commandParcelType"];
    [aCoder encodeObject:self.to forKey:@"toPeerName"];
    [aCoder encodeObject:self.from forKey:@"replyTo"];
    [aCoder encodeObject:self.responseKey forKey:@"responseKey"];
    [aCoder encodeObject:self.object forKey:@"object"];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self)
    {
        self.commandParcelType = [aDecoder decodeIntForKey:@"commandParcelType"];
        self.to = [aDecoder decodeObjectForKey:@"toPeerName"];
        self.from = [aDecoder decodeObjectForKey:@"replyTo"];
        self.responseKey = [aDecoder decodeObjectForKey:@"responseKey"];
        self.object = [aDecoder decodeObjectForKey:@"object"];
    }
    
    return self;
}


@end
