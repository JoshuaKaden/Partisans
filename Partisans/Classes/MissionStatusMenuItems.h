//
//  MissionStatusMenuItems.h
//  Partisans
//
//  Created by Joshua Kaden on 7/8/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSKMenuViewController.h"

typedef enum
{
    MissionStatusSectionStatus,
    MissionStatusSectionTeam,
    MissionStatusSection_MaxValue
} MissionStatusSection;

@interface MissionStatusMenuItems : NSObject <JSKMenuViewControllerDelegate>

@end
