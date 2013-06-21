//
//  OperativeAlertMenuItems.h
//  Partisans
//
//  Created by Joshua Kaden on 6/21/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSKMenuViewController.h"

typedef enum
{
    OperativeAlertMenuSectionStatus,
    OperativeAlertMenuSectionList,
    OperativeAlertMenuSectionCommand,
    OperativeAlertMenuSection_MaxValue
} OperativeAlertMenuSection;

@interface OperativeAlertMenuItems : NSObject <JSKMenuViewControllerDelegate>

@end
