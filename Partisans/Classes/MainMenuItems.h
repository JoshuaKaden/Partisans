//
//  MainMenuItems.h
//  QuestPlayer
//
//  Created by Joshua Kaden on 4/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSKMenuViewController.h"


typedef enum
{
    MainMenuRowPlayer,
    MainMenuRowQuests,
    MainMenuRowSettings,
    MainMenuRowTools,
    MainMenuRow_MaxValue
} MainMenuRow;


@interface MainMenuItems : NSObject <JSKMenuViewControllerDelegate>

@end

