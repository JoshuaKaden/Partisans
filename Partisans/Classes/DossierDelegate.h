//
//  DossierDelegate.h
//  Partisans
//
//  Created by Joshua Kaden on 7/22/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DossierViewController.h"

@class PlayerEnvoy;

@interface DossierDelegate : NSObject <DossierViewControllerDelegate>

@property (nonatomic, strong) PlayerEnvoy *playerEnvoy;

- (id)initWithPlayerEnvoy:(PlayerEnvoy *)playerEnvoy;

@end
