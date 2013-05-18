//
//  CreateGameOperation.h
//  Partisans
//
//  Created by Joshua Kaden on 5/18/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GameEnvoy;

@interface CreateGameOperation : NSOperation

@property (nonatomic, strong) GameEnvoy *envoy;

- (id)initWithEnvoy:(GameEnvoy *)envoy;

@end
