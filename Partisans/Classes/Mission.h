//
//  Mission.h
//  Partisans
//
//  Created by Joshua Kaden on 7/9/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Game, GamePlayer, Round;

@interface Mission : NSManagedObject

@property (nonatomic, retain) NSNumber * didSucceed;
@property (nonatomic, retain) NSNumber * hasStarted;
@property (nonatomic, retain) NSString * intramuralID;
@property (nonatomic, retain) NSNumber * isComplete;
@property (nonatomic, retain) NSString * missionName;
@property (nonatomic, retain) NSNumber * missionNumber;
@property (nonatomic, retain) NSNumber * teamCount;
@property (nonatomic, retain) Game *game;
@property (nonatomic, retain) NSSet *rounds;
@property (nonatomic, retain) NSSet *teamMembers;
@property (nonatomic, retain) NSSet *saboteurs;
@property (nonatomic, retain) NSSet *contributeurs;
@property (nonatomic, retain) GamePlayer *coordinator;
@end

@interface Mission (CoreDataGeneratedAccessors)

- (void)addRoundsObject:(Round *)value;
- (void)removeRoundsObject:(Round *)value;
- (void)addRounds:(NSSet *)values;
- (void)removeRounds:(NSSet *)values;

- (void)addTeamMembersObject:(GamePlayer *)value;
- (void)removeTeamMembersObject:(GamePlayer *)value;
- (void)addTeamMembers:(NSSet *)values;
- (void)removeTeamMembers:(NSSet *)values;

- (void)addSaboteursObject:(GamePlayer *)value;
- (void)removeSaboteursObject:(GamePlayer *)value;
- (void)addSaboteurs:(NSSet *)values;
- (void)removeSaboteurs:(NSSet *)values;

- (void)addContributeursObject:(GamePlayer *)value;
- (void)removeContributeursObject:(GamePlayer *)value;
- (void)addContributeurs:(NSSet *)values;
- (void)removeContributeurs:(NSSet *)values;

@end
