//
//  AboutMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 7/12/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "AboutMenuItems.h"

@implementation AboutMenuItems


#pragma mark - Menu View Controller delegate

- (NSString *)menuViewControllerTitle:(JSKMenuViewController *)menuViewController
{
    NSString *title = NSLocalizedString(@"About", @"About  --  title");
    return title;
}

- (NSInteger)menuViewControllerNumberOfSections:(JSKMenuViewController *)menuViewController
{
    return 1;
}

- (NSInteger)menuViewController:(JSKMenuViewController *)menuViewController numberOfRowsInSection:(NSInteger)section
{
    return AboutRow_MaxValue;
}

- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController labelAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *returnValue = nil;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    AboutRow menuRow = (AboutRow)indexPath.row;
    switch (menuRow)
    {
        case AboutRowName:
            returnValue = [infoDictionary objectForKey:@"CFBundleDisplayName"];
            break;
        case AboutRowVersion:
            returnValue = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
            break;
        case AboutRowBuild:
            returnValue = [infoDictionary objectForKey:@"CFBundleVersion"];
            break;
        case AboutRow_MaxValue:
            break;
    }
    return returnValue;
}

- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController subLabelAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *returnValue = nil;
    AboutRow menuRow = (AboutRow)indexPath.row;
    switch (menuRow)
    {
        case AboutRowName:
//            returnValue = NSLocalizedString(@"Name", @"Name  --  sub label");
            break;
        case AboutRowVersion:
            returnValue = NSLocalizedString(@"Version", @"Version  --  sub label");
            break;
        case AboutRowBuild:
            returnValue = NSLocalizedString(@"Build", @"Build  --  sub label");
            break;
        case AboutRow_MaxValue:
            break;
    }
    return returnValue;
}

- (UIImage *)menuViewController:(JSKMenuViewController *)menuViewController imageForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == AboutRowName)
    {
        return [UIImage imageNamed:@"Icon"];
    }
    else
    {
        return nil;
    }
}

- (Class)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerClassAtIndexPath:(NSIndexPath *)indexPath
{
    Class returnValue = nil;
    return returnValue;
}

- (BOOL)menuViewControllerHidesBackButton:(JSKMenuViewController *)menuViewController
{
    return NO;
}

- (BOOL)menuViewControllerHidesRefreshButton:(JSKMenuViewController *)menuViewController
{
    return YES;
}

- (BOOL)menuViewControllerShouldAutoRefresh:(JSKMenuViewController *)menuViewController
{
    return NO;
}

- (UITableViewCellAccessoryType)menuViewController:(JSKMenuViewController *)menuViewController cellAccessoryTypeForIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellAccessoryNone;
}

@end
