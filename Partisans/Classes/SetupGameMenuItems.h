//
//  SetupGameMenuItems.h
//  Partisans
//
//  Created by Joshua Kaden on 5/15/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSKMenuViewController.h"


typedef enum
{
    SetupGameMenuSectionGame,
    SetupGameMenuSectionAwaitingApproval,
    SetupGameMenuSectionPlayers,
    SetupGameMenuSection_MaxValue
} SetupGameMenuSection;

typedef enum
{
    SetupGameMenuRowHost,
    SetupGameMenuRowPlayers,
    SetupGameMenuRowStatus,
    SetupGameMenuRow_MaxValue
} SetupGameMenuRow;


@interface SetupGameMenuItems : NSObject <JSKMenuViewControllerDelegate>

@property (nonatomic, assign) BOOL shouldHost;

@end
