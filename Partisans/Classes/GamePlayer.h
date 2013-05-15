//
//  GamePlayer.h
//  Partisans
//
//  Created by Joshua Kaden on 5/15/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Game, Mission, Player, Round, Votes;

@interface GamePlayer : NSManagedObject

@property (nonatomic, retain) NSString * intramuralID;
@property (nonatomic, retain) NSNumber * isOperative;
@property (nonatomic, retain) Game *game;
@property (nonatomic, retain) Player *player;
@property (nonatomic, retain) NSSet *leaderForRounds;
@property (nonatomic, retain) NSSet *missions;
@property (nonatomic, retain) NSSet *candidateForRounds;
@property (nonatomic, retain) NSSet *votes;
@end

@interface GamePlayer (CoreDataGeneratedAccessors)

- (void)addLeaderForRoundsObject:(Round *)value;
- (void)removeLeaderForRoundsObject:(Round *)value;
- (void)addLeaderForRounds:(NSSet *)values;
- (void)removeLeaderForRounds:(NSSet *)values;

- (void)addMissionsObject:(Mission *)value;
- (void)removeMissionsObject:(Mission *)value;
- (void)addMissions:(NSSet *)values;
- (void)removeMissions:(NSSet *)values;

- (void)addCandidateForRoundsObject:(Round *)value;
- (void)removeCandidateForRoundsObject:(Round *)value;
- (void)addCandidateForRounds:(NSSet *)values;
- (void)removeCandidateForRounds:(NSSet *)values;

- (void)addVotesObject:(Votes *)value;
- (void)removeVotesObject:(Votes *)value;
- (void)addVotes:(NSSet *)values;
- (void)removeVotes:(NSSet *)values;

@end
