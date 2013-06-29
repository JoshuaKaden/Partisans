//
//  PlayerRoundMenuItems.h
//  Partisans
//
//  Created by Joshua Kaden on 6/25/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSKMenuViewController.h"

typedef enum
{
    RoundMenuSectionMission,
    RoundMenuSectionTeam,
    RoundMenuSectionCommand,
    RoundMenuSection_MaxValue
} RoundMenuSection;

typedef enum
{
    RoundMenuMissionRowName,
    RoundMenuMissionRowCoordinator,
    RoundMenuMissionRow_MaxValue
} RoundMenuMissionRow;

@interface RoundMenuItems : NSObject <JSKMenuViewControllerDelegate>

@end
