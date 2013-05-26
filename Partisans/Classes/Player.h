//
//  Player.h
//  Partisans
//
//  Created by Joshua Kaden on 5/25/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class GamePlayer, Image, Scorecard;

@interface Player : NSManagedObject

@property (nonatomic, retain) id favoriteColor;
@property (nonatomic, retain) NSString * intramuralID;
@property (nonatomic, retain) NSNumber * isDefault;
@property (nonatomic, retain) NSNumber * isDefaultPicture;
@property (nonatomic, retain) NSNumber * isNative;
@property (nonatomic, retain) NSDate * modifiedDate;
@property (nonatomic, retain) NSString * peerID;
@property (nonatomic, retain) NSString * playerName;
@property (nonatomic, retain) GamePlayer *gamePlayer;
@property (nonatomic, retain) Scorecard *operativeScorecard;
@property (nonatomic, retain) Scorecard *partisanScorecard;
@property (nonatomic, retain) Image *picture;

@end
