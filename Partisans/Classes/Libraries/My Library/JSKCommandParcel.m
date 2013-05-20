//
//  JSKCommandParcel.m
//  Partisans
//
//  Created by Joshua Kaden on 5/10/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "JSKCommandParcel.h"

@implementation JSKCommandParcel

@synthesize commandParcelType = m_commandParcelType;
@synthesize to = m_to;
@synthesize from = m_from;
@synthesize respondingToType = m_respondingToType;
@synthesize object = m_object;

- (void)dealloc
{
    [m_to release];
    [m_from release];
    [m_object release];
    [super dealloc];
}



- (id)initWithType:(JSKCommandParcelType)commandParcelType
                to:(NSString *)to
              from:(NSString *)from
            object:(id<NSCoding>)object
{
    self = [super init];
    if (self)
    {
        self.commandParcelType = commandParcelType;
        self.to = to;
        self.from = from;
        self.respondingToType = JSKCommandMessageTypeUnknown;
        [self setObject:(NSObject <NSCoding> *)object];
    }
    return self;
}


- (id)initWithType:(JSKCommandParcelType)commandParcelType
                to:(NSString *)to
              from:(NSString *)from
      respondingTo:(JSKCommandMessageType)respondingTo
{
    self = [super init];
    if (self)
    {
        self.commandParcelType = commandParcelType;
        self.to = to;
        self.from = from;
        self.respondingToType = respondingTo;
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
    
    NSString *typeString = self.commandParcelTypeName;
    if (!typeString)
    {
        typeString = @"";
    }
    
    NSString *respondingToString = [JSKCommandMessage messageTypeName:self.respondingToType];
    if (!respondingToString)
    {
        respondingToString = @"";
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
                              [NSNumber numberWithInt:self.respondingToType].description, @"respondingToCommandMessageType",
                              respondingToString, @"respondingToName",
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
        case JSKCommandParcelTypePlayerJoined:
            name = @"PlayerJoined";
            break;

        case JSKCommandParcelTypePlayerLeft:
            name = @"PlayerLeft";
            break;

        case JSKCommandParcelTypeResponse:
            name = @"Response";
            break;
            
        case JSKCommandParcelTypeUnknown:
            name = @"Unknown";
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
    [aCoder encodeInt:self.respondingToType forKey:@"respondingToType"];
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
        self.respondingToType = [aDecoder decodeIntForKey:@"respondingToType"];
        self.object = [aDecoder decodeObjectForKey:@"object"];
    }
    
    return self;
}


@end
