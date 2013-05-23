//
//  ToolsMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 5/23/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "ToolsMenuItems.h"

@implementation ToolsMenuItems

- (void)dealloc
{
    [super dealloc];
}


- (BOOL)menuViewControllerHidesRefreshButton:(JSKMenuViewController *)menuViewController
{
    return YES;
}

- (NSInteger)menuViewControllerNumberOfSections:(JSKMenuViewController *)menuViewController
{
    return 1;
}


- (NSInteger)menuViewController:(JSKMenuViewController *)menuViewController numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return ToolsMenuRow_MaxValue;
    }
    else
    {
        return 0;
    }
}


- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController labelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section > 0)
    {
        return nil;
    }
    
    NSString *label = nil;
    
    switch (indexPath.row)
    {
        case ToolsMenuRowClearRemoteData:
            label = NSLocalizedString(@"Clear Remote Data", @"Clear Remote Data  --  menu label");
            break;

        case ToolsMenuRow_MaxValue:
            break;
    }
    
    return label;
}



- (Class)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerClassAtIndexPath:(NSIndexPath *)indexPath
{
    Class targetClass = nil;
    
    switch (indexPath.row)
    {
        case ToolsMenuRowClearRemoteData:
            break;

        case ToolsMenuRow_MaxValue:
            break;
    }
    
    return targetClass;
}



- (NSString *)menuViewControllerTitle:(JSKMenuViewController *)menuViewController
{
    return NSLocalizedString(@"Tools", @"Tools  --  title");
}

@end
