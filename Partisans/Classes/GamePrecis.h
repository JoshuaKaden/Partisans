//
//  GamePrecis.h
//  Partisans
//
//  Created by Joshua Kaden on 7/16/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GameEnvoy;

@interface GamePrecis : NSObject <NSCoding>

@property (nonatomic, strong) NSString *intramuralID;
@property (nonatomic, strong) NSDate *modifiedDate;

- (id)initWithEnvoy:(GameEnvoy *)envoy;

@end
