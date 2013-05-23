//
//  GameEnvoy.h
//  Partisans
//
//  Created by Joshua Kaden on 5/15/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Game;
@class NSManagedObjectID;
@class PlayerEnvoy;

@interface GameEnvoy : NSObject <NSCoding>

@property (nonatomic, strong) NSManagedObjectID *managedObjectID;
@property (nonatomic, strong) NSString *intramuralID;
@property (nonatomic, strong) NSString *importedObjectString;

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, assign) NSUInteger numberOfPlayers;

- (NSArray *)players;
- (PlayerEnvoy *)host;
- (void)addPlayer:(PlayerEnvoy *)playerEnvoy;
- (BOOL)isPlayerInGame:(PlayerEnvoy *)playerEnvoy;
- (void)removePlayer:(PlayerEnvoy *)playerEnvoy;
- (void)addHost:(PlayerEnvoy *)playerEnvoy;

+ (GameEnvoy *)envoyFromHost:(PlayerEnvoy *)host;
+ (GameEnvoy *)envoyFromPlayer:(PlayerEnvoy *)player;

+ (GameEnvoy *)envoyFromManagedObject:(Game *)managedObject;

- (id)initWithManagedObject:(Game *)managedObject;

- (void)deleteGame;

- (void)commit;
- (void)commitAndSave;
- (void)commitInContext:(NSManagedObjectContext *)context;

@end
