//
//  GameOverMenuItems.h
//  Partisans
//
//  Created by Joshua Kaden on 7/13/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSKMenuViewController.h"

typedef enum
{
    GameOverSectionSummary,
    GameOverSectionCommand,
    GameOverSectionPlayers,
    GameOverSection_MaxValue
} GameOverSection;

typedef enum
{
    GameOverSummaryRowResult,
    GameOverSummaryRowReason,
    GameOverSummaryRow_MaxValue
} GameOverSummaryRow;

@interface GameOverMenuItems : NSObject <JSKMenuViewControllerDelegate>

@end
