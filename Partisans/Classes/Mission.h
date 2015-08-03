//
//  Mission.h
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

@class Game, GamePlayer, Round;

@interface Mission : NSManagedObject

@property (nonatomic, strong) NSNumber * didSucceed;
@property (nonatomic, strong) NSNumber * hasStarted;
@property (nonatomic, strong) NSString * intramuralID;
@property (nonatomic, strong) NSNumber * isComplete;
@property (nonatomic, strong) NSString * missionName;
@property (nonatomic, strong) NSNumber * missionNumber;
@property (nonatomic, strong) NSNumber * teamCount;
@property (nonatomic, strong) Game *game;
@property (nonatomic, strong) NSSet *rounds;
@property (nonatomic, strong) NSSet *teamMembers;
@property (nonatomic, strong) NSSet *saboteurs;
@property (nonatomic, strong) NSSet *contributeurs;
@property (nonatomic, strong) GamePlayer *coordinator;
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
