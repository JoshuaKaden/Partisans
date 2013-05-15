//
//  Image.h
//  Partisans
//
//  Created by Joshua Kaden on 5/15/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Player;

@interface Image : NSManagedObject

@property (nonatomic, retain) NSDate * dateSaved;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSDate * imageDate;
@property (nonatomic, retain) NSNumber * imageLatitude;
@property (nonatomic, retain) NSNumber * imageLongitude;
@property (nonatomic, retain) NSNumber * imageSource;
@property (nonatomic, retain) NSString * intramuralID;
@property (nonatomic, retain) Player *player;

@end
