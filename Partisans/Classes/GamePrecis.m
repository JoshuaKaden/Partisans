//
//  GamePrecis.m
//  Partisans
//
//  Created by Joshua Kaden on 7/16/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "GamePrecis.h"
#import "GameEnvoy.h"

@implementation GamePrecis

@synthesize intramuralID = m_intramuralID;
@synthesize modifiedDate = m_modifedDate;

- (void)dealloc
{
    [m_intramuralID release];
    [m_modifedDate release];
    [super dealloc];
}

- (id)initWithEnvoy:(GameEnvoy *)envoy
{
    self = [super init];
    if (self)
    {
        self.intramuralID = envoy.intramuralID;
        self.modifiedDate = envoy.modifiedDate;
    }
    return self;
}

- (NSString *)description
{
    NSDictionary *descDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"GamePrecis", @"Class",
                              self.intramuralID, @"intramuralID",
                              self.modifiedDate.description, @"modifiedDate", nil];
    return descDict.description;
}


#pragma mark - NSCoder methods

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.intramuralID forKey:@"intramuralID"];
    [aCoder encodeObject:self.modifiedDate forKey:@"modifiedDate"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.intramuralID = [aDecoder decodeObjectForKey:@"intramuralID"];
        self.modifiedDate = [aDecoder decodeObjectForKey:@"modifiedDate"];
    }
    return self;
}

@end
