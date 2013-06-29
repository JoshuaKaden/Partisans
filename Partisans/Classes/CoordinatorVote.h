//
//  CoordinatorVote.h
//  Partisans
//
//  Created by Joshua Kaden on 6/28/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VoteEnvoy;

// This includes:
//      a list of mission team candidate IDs, and
//      a Vote Envoy.
// A given Round's Mission Coordinator will send this to the Host,
// as a way of kicking-off the voting process.
@interface CoordinatorVote : NSObject <NSCoding>

@property (nonatomic, strong) NSArray *candidateIDs;
@property (nonatomic, strong) VoteEnvoy *voteEnvoy;

@end
