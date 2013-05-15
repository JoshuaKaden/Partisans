//
//  Scorecard.h
//  Partisans
//
//  Created by Joshua Kaden on 5/15/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Player;

@interface Scorecard : NSManagedObject

@property (nonatomic, retain) NSNumber * gamesWon;
@property (nonatomic, retain) NSNumber * gamesPlayed;
@property (nonatomic, retain) NSNumber * missionsPerformed;
@property (nonatomic, retain) NSNumber * missionsSabotaged;
@property (nonatomic, retain) NSNumber * missionsLed;
@property (nonatomic, retain) NSNumber * successfulMissionsLed;
@property (nonatomic, retain) Player *partisanPlayer;
@property (nonatomic, retain) Player *operativePlayer;

@end
