//
//  CoordinatorVote.m
//  Partisans
//
//  Created by Joshua Kaden on 6/28/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "CoordinatorVote.h"
#import "VoteEnvoy.h"

@implementation CoordinatorVote

@synthesize candidateIDs = m_candidateIDs;
@synthesize voteEnvoy = m_voteEnvoy;

- (void)dealloc
{
    [m_candidateIDs release];
    [m_voteEnvoy release];
    [super dealloc];
}

- (NSString *)description
{
    NSDictionary *descDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"CoordinatorVote", @"Class",
                              self.candidateIDs, @"candidateIDs",
                              self.voteEnvoy, @"voteEnvoy", nil];
    return descDict.description;
}


#pragma mark - NSCoder methods

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.candidateIDs forKey:@"candidateIDs"];
    [aCoder encodeObject:self.voteEnvoy forKey:@"voteEnvoy"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.candidateIDs = [aDecoder decodeObjectForKey:@"candidateIDs"];
        self.voteEnvoy = [aDecoder decodeObjectForKey:@"voteEnvoy"];
    }
    return self;
}

@end
