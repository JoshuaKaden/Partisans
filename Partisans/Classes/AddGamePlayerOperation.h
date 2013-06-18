//
//  AddGamePlayerOperation.h
//  Partisans
//
//  Created by Joshua Kaden on 5/17/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PlayerEnvoy;
@class GameEnvoy;

@interface AddGamePlayerOperation : NSOperation

- (id)initWithPlayerEnvoy:(PlayerEnvoy *)playerEnvoy gameEnvoy:(GameEnvoy *)gameEnvoy;

@end

