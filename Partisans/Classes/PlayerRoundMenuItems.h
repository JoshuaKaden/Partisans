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
    PlayerRoundMenuSectionMission,
    PlayerRoundMenuSectionTeam,
    PlayerRoundMenuSectionCommand,
    PlayerRoundMenuSection_MaxValue
} PlayerRoundMenuSection;

typedef enum
{
    PlayerRoundMenuMissionRowName,
    PlayerRoundMenuMissionRowCoordinator,
    PlayerRoundMenuMissionRow_MaxValue
} PlayerRoundMenuMissionRow;

@interface PlayerRoundMenuItems : NSObject <JSKMenuViewControllerDelegate>

@end
