//
//  MainMenuItems.h
//  Partisans
//
//  Created by Joshua Kaden on 4/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSKMenuViewController.h"


typedef enum
{
    MainMenuRowPlayer,
    MainMenuRowGame,
    MainMenuRowScores,
    MainMenuRowAccomplishments,
    MainMenuRow_MaxValue
} MainMenuRow;


@interface MainMenuItems : NSObject <JSKMenuViewControllerDelegate>

@end

