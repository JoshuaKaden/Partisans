//
//  GameEnvoy.h
//  Partisans
//
//  Created by Joshua Kaden on 5/15/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
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

@property (readonly) NSUInteger operativeCount;
@property (readonly) NSUInteger roundCount;
@property (nonatomic, readonly) NSArray *missionEnvoys;

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

@end
