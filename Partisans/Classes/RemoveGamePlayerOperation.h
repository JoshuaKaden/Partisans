//
//  RemoveGamePlayerOperation.h
//  Partisans
//
//  Created by Joshua Kaden on 5/20/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PlayerEnvoy;

@interface RemoveGamePlayerOperation : NSOperation

@property (nonatomic, strong) PlayerEnvoy *envoy;

- (id)initWithEnvoy:(PlayerEnvoy *)envoy;

@end

