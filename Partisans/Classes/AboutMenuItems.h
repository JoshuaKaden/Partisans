//
//  AboutMenuItems.h
//  Partisans
//
//  Created by Joshua Kaden on 7/12/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSKMenuViewController.h"

typedef enum
{
    AboutRowName,
    AboutRowVersion,
    AboutRowBuild,
    AboutRow_MaxValue
} AboutRow;

@interface AboutMenuItems : NSObject <JSKMenuViewControllerDelegate>

@end
