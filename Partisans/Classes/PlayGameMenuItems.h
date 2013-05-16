//
//  PlayGameMenuItems.h
//  Partisans
//
//  Created by Joshua Kaden on 5/15/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSKMenuViewController.h"


typedef enum
{
    PlayGameMenuRowHost,
    PlayGameMenuRowJoin,
    PlayGameMenuRow_MaxValue
} PlayGameMenuRow;


@interface PlayGameMenuItems : NSObject <JSKMenuViewControllerDelegate>

@end
