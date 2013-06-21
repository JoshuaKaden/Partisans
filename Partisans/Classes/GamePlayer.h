//
//  GamePlayer.h
//  Partisans
//
//  Created by Joshua Kaden on 6/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Game, Mission, Player, Round, Votes;

@interface GamePlayer : NSManagedObject

@property (nonatomic, retain) NSString * intramuralID;
@property (nonatomic, retain) NSNumber * isHost;
@property (nonatomic, retain) NSNumber * isOperative;
@property (nonatomic, retain) NSSet *candidateForRounds;
@property (nonatomic, retain) Game *game;
@property (nonatomic, retain) NSSet *leaderForRounds;
@property (nonatomic, retain) NSSet *missionVotes;
@property (nonatomic, retain) Player *player;
@property (nonatomic, retain) NSSet *teamMemberOn;
@end

@interface GamePlayer (CoreDataGeneratedAccessors)

- (void)addCandidateForRoundsObject:(Round *)value;
- (void)removeCandidateForRoundsObject:(Round *)value;
- (void)addCandidateForRounds:(NSSet *)values;
- (void)removeCandidateForRounds:(NSSet *)values;

- (void)addLeaderForRoundsObject:(Round *)value;
- (void)removeLeaderForRoundsObject:(Round *)value;
- (void)addLeaderForRounds:(NSSet *)values;
- (void)removeLeaderForRounds:(NSSet *)values;

- (void)addMissionVotesObject:(Votes *)value;
- (void)removeMissionVotesObject:(Votes *)value;
- (void)addMissionVotes:(NSSet *)values;
- (void)removeMissionVotes:(NSSet *)values;

- (void)addTeamMemberOnObject:(Mission *)value;
- (void)removeTeamMemberOnObject:(Mission *)value;
- (void)addTeamMemberOn:(NSSet *)values;
- (void)removeTeamMemberOn:(NSSet *)values;

@end
