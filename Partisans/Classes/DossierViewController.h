//
//  DossierViewController.h
//  Partisans
//
//  Created by Joshua Kaden on 7/20/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DossierViewController;
@class PlayerEnvoy;


@protocol DossierViewControllerDelegate <NSObject>

- (PlayerEnvoy *)supplyPlayerEnvoy:(DossierViewController *)dossierViewController;

@end


@interface DossierViewController : UIViewController

@property (nonatomic, assign) id <DossierViewControllerDelegate> delegate;

@end
