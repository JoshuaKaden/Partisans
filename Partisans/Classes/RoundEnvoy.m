//
//  RoundEnvoy.m
//  Partisans
//
//  Created by Joshua Kaden on 6/20/13.
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

#import "RoundEnvoy.h"

#import "Game.h"
#import "GameEnvoy.h"
#import "GamePlayer.h"
#import "JSKDataMiner.h"
#import "Mission.h"
#import "MissionEnvoy.h"
#import "NSManagedObjectContext+FetchAdditions.h"
#import "Player.h"
#import "PlayerEnvoy.h"
#import "Round.h"
#import "SystemMessage.h"
#import "Vote.h"
#import "VoteEnvoy.h"


@interface RoundEnvoy ()

@property (nonatomic, strong) NSArray *candidateIDs;
@property (nonatomic, strong) NSArray *voteEnvoys;

- (void)loadCandidateIDs;
- (void)loadVoteEnvoys;

@end


@implementation RoundEnvoy

@synthesize managedObjectID = m_managedObjectID;
@synthesize intramuralID = m_intramuralID;
@synthesize roundNumber = m_roundNumber;
@synthesize missionNumber = m_missionNumber;
@synthesize gameID = m_gameID;
@synthesize coordinatorID = m_coordinatorID;
@synthesize candidateIDs = m_candidateIDs;
@synthesize voteEnvoys = m_voteEnvoys;




- (PlayerEnvoy *)coordinator
{
    return [PlayerEnvoy envoyFromIntramuralID:self.coordinatorID];
}

#pragma mark - Mission Team Candidates

- (NSArray *)candidates
{
    if (self.candidateIDs.count == 0)
    {
        return [NSArray array];
    }
    
    NSMutableArray *candidateList = [[NSMutableArray alloc] initWithCapacity:self.candidateIDs.count];
    for (NSString *candidateID in self.candidateIDs)
    {
        [candidateList addObject:[PlayerEnvoy envoyFromIntramuralID:candidateID]];
    }
    NSArray *returnValue = [NSArray arrayWithArray:candidateList];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"playerName" ascending:YES];
    returnValue = [returnValue sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    return returnValue;
}

- (void)addCandidate:(PlayerEnvoy *)playerEnvoy
{
    if (self.candidateIDs.count == 0)
    {
        self.candidateIDs = [NSArray arrayWithObject:playerEnvoy.intramuralID];
        return;
    }
    MissionEnvoy *missionEnvoy = [[SystemMessage gameEnvoy] currentMission];
    if (missionEnvoy.teamCount > self.candidateIDs.count)
    {
        NSArray *candidates = [self.candidateIDs arrayByAddingObject:playerEnvoy.intramuralID];
        self.candidateIDs = candidates;
    }
}

- (void)clearCandidates
{
    self.candidateIDs = nil;
}


- (void)loadCandidateIDs
{
    if (!self.managedObjectID)
    {
        return;
    }
    
    Round *model = (Round *)[[JSKDataMiner mainObjectContext] objectWithID:self.managedObjectID];
    NSMutableArray *candidateList = [[NSMutableArray alloc] initWithCapacity:model.missionCandidates.count];
    for (GamePlayer *gamePlayer in model.missionCandidates)
    {
        if (gamePlayer.player)
        {
            [candidateList addObject:gamePlayer.player.intramuralID];
        }
    }
    self.candidateIDs = [NSArray arrayWithArray:candidateList];
}



#pragma mark - Votes

- (void)loadVoteEnvoys
{
    Round *model = (Round *)[[JSKDataMiner mainObjectContext] objectWithID:self.managedObjectID];
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:model.votes.count];
    for (Vote *vote in model.votes)
    {
        VoteEnvoy *voteEnvoy = [[VoteEnvoy alloc] initWithManagedObject:vote];
        [list addObject:voteEnvoy];
    }
    self.voteEnvoys = [NSArray arrayWithArray:list];
}

- (void)addVote:(VoteEnvoy *)voteEnvoy
{
    if (!self.voteEnvoys)
    {
        self.voteEnvoys = [NSArray arrayWithObject:voteEnvoy];
    }
    else
    {
        NSArray *ids = [self.voteEnvoys valueForKey:@"playerID"];
        for (NSString *playerID in ids)
        {
            if ([playerID isEqualToString:voteEnvoy.playerID])
            {
                return;
            }
        }
        self.voteEnvoys = [self.voteEnvoys arrayByAddingObject:voteEnvoy];
    }
}

- (NSArray *)votes
{
    return self.voteEnvoys;
}


- (NSUInteger)votesCast
{
    NSArray *cast = [self.votes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isCast == YES"]];
    return cast.count;
}

- (NSUInteger)yeaVotes
{
    NSArray *yeas = [self.votes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isYea == YES"]];
    return yeas.count;
}

- (NSUInteger)nayVotes
{
    NSArray *nays = [self.votes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isYea == NO"]];
    return nays.count;
}

- (BOOL)hasPlayerVoted:(PlayerEnvoy *)playerEnvoy
{
    BOOL returnValue = NO;
    if (!playerEnvoy)
    {
        playerEnvoy = [SystemMessage playerEnvoy];
    }
    for (VoteEnvoy *voteEnvoy in self.votes)
    {
        if ([voteEnvoy.playerID isEqualToString:playerEnvoy.intramuralID])
        {
            returnValue = YES;
            break;
        }
    }
    return returnValue;
}

- (BOOL)isVotingComplete
{
    NSUInteger playerCount = [SystemMessage gameEnvoy].numberOfPlayers;
    if (self.votes.count == playerCount)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


- (BOOL)voteDidPass
{
    NSUInteger majority = [self yeaMajority];
    if ([self yeaVotes] >= majority)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


- (NSUInteger)yeaMajority
{
    NSUInteger playerCount = [SystemMessage gameEnvoy].numberOfPlayers;
    NSUInteger majority = 3;
    switch (playerCount)
    {
        case 6:
            majority = 4;
            break;
        case 7:
            majority = 4;
            break;
        case 8:
            majority = 5;
            break;
        case 9:
            majority = 5;
            break;
        case 10:
            majority = 6;
            break;
        default:
            break;
    }
    return majority;
}

- (NSUInteger)nayMajority
{
    NSUInteger playerCount = [SystemMessage gameEnvoy].numberOfPlayers;
    NSUInteger majority = 3;
    switch (playerCount)
    {
        case 6:
            majority = 3;
            break;
        case 7:
            majority = 4;
            break;
        case 8:
            majority = 4;
            break;
        case 9:
            majority = 5;
            break;
        case 10:
            majority = 5;
            break;
        default:
            break;
    }
    return majority;
}



#pragma mark - Overrides

- (NSArray *)candidateIDs
{
    if (!m_candidateIDs)
    {
        self.candidateIDs = [NSArray array];
    }
    return m_candidateIDs;
}


#pragma mark - Envoy

- (id)initWithManagedObject:(Round *)managedObject
{
    self = [super init];
    if (self)
    {
        self.managedObjectID = managedObject.objectID;
        self.intramuralID    = managedObject.intramuralID;
        if (!self.intramuralID)
        {
            self.intramuralID = [[self.managedObjectID URIRepresentation] absoluteString];
        }
        self.roundNumber     = [managedObject.roundNumber unsignedIntegerValue];
        self.missionNumber   = [managedObject.mission.missionNumber unsignedIntegerValue];
        self.gameID          = managedObject.game.intramuralID;
        self.coordinatorID   = managedObject.leader.player.intramuralID;
        
        [self loadCandidateIDs];
        [self loadVoteEnvoys];
    }
    return self;
}


+ (RoundEnvoy *)envoyFromManagedObject:(Round *)managedObject
{
    RoundEnvoy *envoy = [[RoundEnvoy alloc] initWithManagedObject:managedObject];
    return envoy;
}



- (NSString *)description
{
    NSString *intramuralIDString = self.intramuralID;
    if (!intramuralIDString)
    {
        intramuralIDString = @"";
    }
    
    NSString *managedObjectString = self.managedObjectID.debugDescription;
    if (!managedObjectString)
    {
        managedObjectString = @"";
    }
        
    NSString *gameIDString = self.gameID;
    if (!gameIDString)
    {
        gameIDString = @"";
    }
    
    NSString *coordinatorIDString = self.coordinatorID;
    if (!coordinatorIDString)
    {
        coordinatorIDString = @"";
    }
    
    NSDictionary *descDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"RoundEnvoy", @"Class",
                              intramuralIDString, @"intramuralID",
                              managedObjectString, @"managedObjectID",
                              [NSNumber numberWithUnsignedInteger:self.missionNumber].description, @"missionNumber",
                              [NSNumber numberWithUnsignedInteger:self.roundNumber].description, @"roundNumber",
                              gameIDString, @"gameID",
                              coordinatorIDString, @"coordinatorID",
                              self.candidateIDs, @"candidateIDs",
                              self.voteEnvoys, @"voteEnvoys", nil];
    return descDict.description;
}


#pragma mark - Commits

- (void)commit
{
    [self commitInContext:nil];
}

- (void)commitAndSave
{
    [self commitInContext:nil];
    [JSKDataMiner save];
}

- (void)commitInContext:(NSManagedObjectContext *)context
{
    if (!context)
    {
        context = [JSKDataMiner sharedInstance].mainObjectContext;
    }
    
    Round *model = nil;
    if (self.managedObjectID)
    {
        model = (Round *)[context objectWithID:self.managedObjectID];
    }
    
    // This could be an update from the host in which case we have to hook up to the correct via the intramural ID.
    if (!model)
    {
        if (self.intramuralID)
        {
            NSArray *list = [context fetchObjectArrayForEntityName:@"Round" withPredicateFormat:@"intramuralID == %@", self.intramuralID];
            if (list.count > 0)
            {
                model = [list objectAtIndex:0];
                self.managedObjectID = model.objectID;
            }
        }
    }
    
    if (!model)
    {
        model = [NSEntityDescription insertNewObjectForEntityForName:@"Round" inManagedObjectContext:context];
    }
    
    model.intramuralID = self.intramuralID;
    
    model.roundNumber = [NSNumber numberWithUnsignedInteger:self.roundNumber];
    
    
    // The game.
    if (!model.game)
    {
        NSArray *list = [context fetchObjectArrayForEntityName:@"Game" withPredicateFormat:@"intramuralID == %@", self.gameID];
        model.game = [list objectAtIndex:0];
    }
    
    
    // The mission.
    if (!model.mission)
    {
        for (Mission *mission in model.game.missions)
        {
            if ([mission.missionNumber isEqualToNumber:[NSNumber numberWithUnsignedInteger:self.missionNumber]])
            {
                model.mission = mission;
                break;
            }
        }
    }
    
    // The coordinator.
    if (!model.leader)
    {
        for (GamePlayer *gamePlayer in model.game.gamePlayers)
        {
            if ([gamePlayer.player.intramuralID isEqualToString:self.coordinatorID])
            {
                model.leader = gamePlayer;
                break;
            }
        }
    }
    
    
    // The candidates.
    if (self.candidateIDs.count == 0)
    {
        [model removeMissionCandidates:model.missionCandidates];
    }
    else
    {
        for (NSString *candidateID in self.candidateIDs)
        {
            NSArray *gamePlayers = [context fetchObjectArrayForEntityName:@"GamePlayer" withPredicateFormat:@"player.intramuralID == %@", candidateID];
            if (gamePlayers.count > 0)
            {
                GamePlayer *gamePlayer = [gamePlayers objectAtIndex:0];
                [model addMissionCandidatesObject:gamePlayer];
            }
        }
    }
    
    
    // The votes.
    for (VoteEnvoy *voteEnvoy in self.voteEnvoys)
    {
        [voteEnvoy commitInContext:context];
    }
    

    
    // Make sure the envoy knows the new managed object ID, if this is an add.
    if (!self.managedObjectID)
    {
        NSError *error = nil;
        [context obtainPermanentIDsForObjects:[NSArray arrayWithObject:model] error:&error];
        if (!error)
        {
            self.managedObjectID = model.objectID;
        }
    }
    
    if (!self.intramuralID)
    {
        self.intramuralID = [[self.managedObjectID URIRepresentation] absoluteString];
        model.intramuralID = self.intramuralID;
    }
}




#pragma mark - NSCoder methods


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.intramuralID forKey:@"intramuralID"];
    
    [aCoder encodeInteger:self.missionNumber forKey:@"missionNumber"];
    [aCoder encodeInteger:self.roundNumber forKey:@"roundNumber"];
    [aCoder encodeObject:self.gameID forKey:@"gameID"];
    [aCoder encodeObject:self.coordinatorID forKey:@"coordinatorID"];
    [aCoder encodeObject:self.candidateIDs forKey:@"candidateIDs"];
    [aCoder encodeObject:self.voteEnvoys forKey:@"voteEnvoys"];
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self)
    {
        self.intramuralID = [aDecoder decodeObjectForKey:@"intramuralID"];
        
        self.missionNumber = [aDecoder decodeIntegerForKey:@"missionNumber"];
        self.roundNumber = [aDecoder decodeIntegerForKey:@"roundNumber"];
        self.gameID = [aDecoder decodeObjectForKey:@"gameID"];
        self.coordinatorID = [aDecoder decodeObjectForKey:@"coordinatorID"];
        self.candidateIDs = [aDecoder decodeObjectForKey:@"candidateIDs"];
        self.voteEnvoys = [aDecoder decodeObjectForKey:@"voteEnvoys"];
    }
    
    return self;
}


@end
