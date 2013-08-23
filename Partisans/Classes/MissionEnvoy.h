//
//  MissionEnvoy.h
//  Partisans
//
//  Created by Joshua Kaden on 6/19/13.
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

@class Mission;
@class NSManagedObjectID;
@class PlayerEnvoy;

@interface MissionEnvoy : NSObject <NSCoding>

@property (nonatomic, strong) NSManagedObjectID *managedObjectID;
@property (nonatomic, strong) NSString *intramuralID;

@property (nonatomic, assign) BOOL hasStarted;
@property (nonatomic, assign) BOOL didSucceed;
@property (nonatomic, assign) BOOL isComplete;
@property (nonatomic, strong) NSString *missionName;
@property (nonatomic, assign) NSUInteger missionNumber;
@property (nonatomic, assign) NSUInteger teamCount;
@property (nonatomic, strong) NSString *gameID;
@property (nonatomic, strong) PlayerEnvoy *coordinator;

- (void)applyTeamMembers:(NSArray *)teamMembers;
- (NSArray *)teamMembers;
- (BOOL)isPlayerOnTeam:(PlayerEnvoy *)playerEnvoy;

- (void)applySaboteur:(PlayerEnvoy *)saboteur;
- (NSArray *)saboteurs;

- (void)applyContributeur:(PlayerEnvoy *)contributeur;
- (NSArray *)contributeurs;

- (BOOL)hasPlayerPerformed:(PlayerEnvoy *)playerEnvoy;
- (NSUInteger)roundCount;

+ (MissionEnvoy *)envoyFromManagedObject:(Mission *)managedObject;

- (id)initWithManagedObject:(Mission *)managedObject;

- (void)commit;
- (void)commitAndSave;
- (void)commitInContext:(NSManagedObjectContext *)context;

@end
