//
//  AddGamePlayerOperation.h
//  Partisans
//
//  Created by Joshua Kaden on 5/17/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PlayerEnvoy;

@interface AddGamePlayerOperation : NSOperation

@property (nonatomic, strong) PlayerEnvoy *envoy;

- (id)initWithEnvoy:(PlayerEnvoy *)envoy;

@end

