//
//  GameEnvoy.h
//  Partisans
//
//  Created by Joshua Kaden on 5/15/13.
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

@class Game;
@class GamePlayerEnvoy;
@class MissionEnvoy;
@class NSManagedObjectID;
@class PlayerEnvoy;
@class RoundEnvoy;

@interface GameEnvoy : NSObject <NSCoding>

@property (nonatomic, strong) NSManagedObjectID *managedObjectID;
@property (nonatomic, strong) NSString *intramuralID;
@property (nonatomic, strong) NSString *importedObjectString;

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, assign) NSUInteger numberOfPlayers;
@property (nonatomic, strong) NSDate *modifiedDate;
@property (nonatomic, assign) NSUInteger gameCode;

@property (readonly) NSUInteger operativeCount;
@property (readonly) NSUInteger roundCount;
@property (nonatomic, readonly) NSArray *missionEnvoys;
@property (nonatomic, assign) BOOL hasScoreBeenShown;

- (NSArray *)players;
- (NSArray *)operatives;
- (PlayerEnvoy *)host;
- (void)addPlayer:(PlayerEnvoy *)playerEnvoy;
- (BOOL)isPlayerInGame:(PlayerEnvoy *)playerEnvoy;
- (BOOL)isPlayerAnOperative:(PlayerEnvoy *)playerEnvoy;
- (void)removePlayer:(PlayerEnvoy *)playerEnvoy;
- (void)addHost:(PlayerEnvoy *)playerEnvoy;
- (void)addMission:(MissionEnvoy *)missionEnvoy;
- (GamePlayerEnvoy *)gamePlayerEnvoyFromPlayer:(PlayerEnvoy *)playerEnvoy;
- (MissionEnvoy *)missionEnvoyFromNumber:(NSUInteger)missionNumber;
- (MissionEnvoy *)currentMission;
- (MissionEnvoy *)firstIncompleteMission;
- (NSUInteger)successfulMissionCount;
- (NSUInteger)failedMissionCount;
- (RoundEnvoy *)roundEnvoyFromNumber:(NSUInteger)roundNumber;
- (RoundEnvoy *)currentRound;
- (void)addRound:(RoundEnvoy *)roundEnvoy;

+ (GameEnvoy *)envoyFromIntramuralID:(NSString *)intramuralID;
+ (GameEnvoy *)envoyFromHost:(PlayerEnvoy *)host;
+ (GameEnvoy *)envoyFromPlayer:(PlayerEnvoy *)player;

+ (GameEnvoy *)envoyFromManagedObject:(Game *)managedObject;

- (id)initWithManagedObject:(Game *)managedObject;

- (void)deleteGame;

- (void)commit;
- (void)commitAndSave;
- (void)commitInContext:(NSManagedObjectContext *)context;
- (void)commitModifiedDate;

@end
