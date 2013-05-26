//
//  Votes.h
//  Partisans
//
//  Created by Joshua Kaden on 5/25/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GamePlayer, Round;

@interface Votes : NSManagedObject

@property (nonatomic, retain) NSString * intramuralID;
@property (nonatomic, retain) NSNumber * isCast;
@property (nonatomic, retain) NSNumber * isYea;
@property (nonatomic, retain) GamePlayer *gamePlayer;
@property (nonatomic, retain) Round *round;

@end
