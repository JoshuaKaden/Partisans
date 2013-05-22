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
@synthesize responseKey = m_responseKey;
@synthesize object = m_object;

- (void)dealloc
{
    [m_to release];
    [m_from release];
    [m_object release];
    [m_responseKey release];
    [super dealloc];
}



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
        case JSKCommandParcelTypeResponse:
            name = @"Response";
            break;
            
        case JSKCommandParcelTypeUpdate:
            name = @"Update";
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
