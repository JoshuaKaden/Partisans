//
//  Game.h
//  Partisans
//
//  Created by Joshua Kaden on 6/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GamePlayer, Mission, Round;

@interface Game : NSManagedObject

@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * intramuralID;
@property (nonatomic, retain) NSDate * modifiedDate;
@property (nonatomic, retain) NSNumber * numberOfPlayers;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSSet *gamePlayers;
@property (nonatomic, retain) NSSet *missions;
@property (nonatomic, retain) NSSet *rounds;
@end

@interface Game (CoreDataGeneratedAccessors)

- (void)addGamePlayersObject:(GamePlayer *)value;
- (void)removeGamePlayersObject:(GamePlayer *)value;
- (void)addGamePlayers:(NSSet *)values;
- (void)removeGamePlayers:(NSSet *)values;

- (void)addMissionsObject:(Mission *)value;
- (void)removeMissionsObject:(Mission *)value;
- (void)addMissions:(NSSet *)values;
- (void)removeMissions:(NSSet *)values;

- (void)addRoundsObject:(Round *)value;
- (void)removeRoundsObject:(Round *)value;
- (void)addRounds:(NSSet *)values;
- (void)removeRounds:(NSSet *)values;

@end
