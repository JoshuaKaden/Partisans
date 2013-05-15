//
//  JSKCommandResponse.m
//  QuestPlayer
//
//  Created by Joshua Kaden on 5/10/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "JSKCommandResponse.h"

@implementation JSKCommandResponse

@synthesize commandResponseType = m_commandResponseType;
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



- (id)initWithType:(JSKCommandResponseType)commandResponseType
                to:(NSString *)to
              from:(NSString *)from
      respondingTo:(JSKCommandMessageType)respondingTo
{
    self = [super init];
    if (self)
    {
        self.commandResponseType = commandResponseType;
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
    
    NSString *typeString = self.commandResponseTypeName;
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
                              @"JSKCommandResponse", @"Class",
                              [NSNumber numberWithInt:self.commandResponseType].description, @"commandResponseType",
                              typeString, @"commandResponseTypeName",
                              fromString, @"from",
                              toString, @"to",
                              [NSNumber numberWithInt:self.respondingToType].description, @"respondingToCommandMessageType",
                              respondingToString, @"respondingToName",
                              objectString, @"object", nil];
    return descDict.description;
}


- (NSString *)commandResponseTypeName
{
    return [JSKCommandResponse responseTypeName:self.commandResponseType];
}




+ (NSString *)responseTypeName:(JSKCommandResponseType)responseType
{
    NSString *name = nil;
    
    switch (responseType)
    {
        case JSKCommandResponseTypeAcknowledge:
            name = @"Acknowledge";
            break;
                        
        case JSKCommandResponseType_maxValue:
            break;
    }
    
    return name;
}




#pragma mark - NSCoder methods


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:self.commandResponseType forKey:@"commandResponseType"];
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
        self.commandResponseType = [aDecoder decodeIntForKey:@"commandResponseType"];
        self.to = [aDecoder decodeObjectForKey:@"toPeerName"];
        self.from = [aDecoder decodeObjectForKey:@"replyTo"];
        self.respondingToType = [aDecoder decodeIntForKey:@"respondingToType"];
        self.object = [aDecoder decodeObjectForKey:@"object"];
    }
    
    return self;
}


@end
