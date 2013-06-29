//
//  Round.h
//  Partisans
//
//  Created by Joshua Kaden on 6/28/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Game, GamePlayer, Mission, Vote;

@interface Round : NSManagedObject

@property (nonatomic, retain) NSString * intramuralID;
@property (nonatomic, retain) NSNumber * roundNumber;
@property (nonatomic, retain) Game *game;
@property (nonatomic, retain) GamePlayer *leader;
@property (nonatomic, retain) Mission *mission;
@property (nonatomic, retain) NSSet *missionCandidates;
@property (nonatomic, retain) NSSet *votes;
@end

@interface Round (CoreDataGeneratedAccessors)

- (void)addMissionCandidatesObject:(GamePlayer *)value;
- (void)removeMissionCandidatesObject:(GamePlayer *)value;
- (void)addMissionCandidates:(NSSet *)values;
- (void)removeMissionCandidates:(NSSet *)values;

- (void)addVotesObject:(Vote *)value;
- (void)removeVotesObject:(Vote *)value;
- (void)addVotes:(NSSet *)values;
- (void)removeVotes:(NSSet *)values;

@end
