//
//  Player.h
//  Partisans
//
//  Created by Joshua Kaden on 5/15/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Image;

@interface Player : NSManagedObject

@property (nonatomic, retain) id favoriteColor;
@property (nonatomic, retain) NSString * intramuralID;
@property (nonatomic, retain) NSNumber * isDefault;
@property (nonatomic, retain) NSNumber * isDefaultPicture;
@property (nonatomic, retain) NSNumber * isNative;
@property (nonatomic, retain) NSDate * modifiedDate;
@property (nonatomic, retain) NSString * peerID;
@property (nonatomic, retain) NSString * playerName;
@property (nonatomic, retain) Image *picture;

@end
