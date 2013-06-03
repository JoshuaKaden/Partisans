//
//  GameSetupTesterMenuItems.h
//  Partisans
//
//  Created by Joshua Kaden on 6/2/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSKMenuViewController.h"

typedef enum
{
    GameTesterMenuSectionAction,
    GameTesterMenuSectionPlayers,
    GameTesterMenuSection_MaxValue
} GameTesterMenuSection;

typedef enum
{
    GameTesterMenuRowAddPlayers,
    GameTesterMenuRowRemovePlayers,
    GameTesterMenuRow_MaxValue
} GameTesterMenuRow;

@interface GameTesterMenuItems : NSObject <JSKMenuViewControllerDelegate>

@end
