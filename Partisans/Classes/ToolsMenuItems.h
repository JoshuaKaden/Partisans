//
//  ToolsMenuItems.h
//  Partisans
//
//  Created by Joshua Kaden on 5/23/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSKMenuViewController.h"


typedef enum
{
    ToolsMenuRowClearRemoteData,
    ToolsMenuRow_MaxValue
} ToolsMenuRow;


@interface ToolsMenuItems : NSObject <JSKMenuViewControllerDelegate>

@end
