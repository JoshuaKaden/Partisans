//
//  PlayerViewController.h
//  Partisans
//
//  Created by Joshua Kaden on 4/24/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PlayerEnvoy;

@interface PlayerViewController : UIViewController

@property (nonatomic, strong) PlayerEnvoy *playerEnvoy;
@property (nonatomic, assign) BOOL shouldHideBackButton;
@property (nonatomic, assign) BOOL isAnAdd;

@end
