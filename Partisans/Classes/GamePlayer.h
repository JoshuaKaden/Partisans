//
//  GamePlayer.h
//  Partisans
//
//  Created by Joshua Kaden on 7/9/13.
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Game, Mission, Player, Round, Vote;

@interface GamePlayer : NSManagedObject

@property (nonatomic, retain) NSNumber * hasAlertBeenShown;
@property (nonatomic, retain) NSString * intramuralID;
@property (nonatomic, retain) NSNumber * isHost;
@property (nonatomic, retain) NSNumber * isOperative;
@property (nonatomic, retain) NSSet *candidateForRounds;
@property (nonatomic, retain) Game *game;
@property (nonatomic, retain) NSSet *leaderForRounds;
@property (nonatomic, retain) NSSet *missionVotes;
@property (nonatomic, retain) Player *player;
@property (nonatomic, retain) NSSet *teamMemberOn;
@property (nonatomic, retain) NSSet *sabotaged;
@property (nonatomic, retain) NSSet *contributed;
@property (nonatomic, retain) NSSet *coordinated;
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

- (void)addMissionVotesObject:(Vote *)value;
- (void)removeMissionVotesObject:(Vote *)value;
- (void)addMissionVotes:(NSSet *)values;
- (void)removeMissionVotes:(NSSet *)values;

- (void)addTeamMemberOnObject:(Mission *)value;
- (void)removeTeamMemberOnObject:(Mission *)value;
- (void)addTeamMemberOn:(NSSet *)values;
- (void)removeTeamMemberOn:(NSSet *)values;

- (void)addSabotagedObject:(Mission *)value;
- (void)removeSabotagedObject:(Mission *)value;
- (void)addSabotaged:(NSSet *)values;
- (void)removeSabotaged:(NSSet *)values;

- (void)addContributedObject:(Mission *)value;
- (void)removeContributedObject:(Mission *)value;
- (void)addContributed:(NSSet *)values;
- (void)removeContributed:(NSSet *)values;

- (void)addCoordinatedObject:(Mission *)value;
- (void)removeCoordinatedObject:(Mission *)value;
- (void)addCoordinated:(NSSet *)values;
- (void)removeCoordinated:(NSSet *)values;

@end
