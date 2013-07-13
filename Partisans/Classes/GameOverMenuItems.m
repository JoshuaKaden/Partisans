//
//  GameOverMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 7/13/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "GameOverMenuItems.h"
#import "SystemMessage.h"


@implementation GameOverMenuItems


#pragma mark - Menu View Controller delegate

- (void)menuViewController:(JSKMenuViewController *)menuViewController didSelectRowAt:(NSIndexPath *)indexPath
{
    if (indexPath.section == GameOverSectionCommand)
    {
        [SystemMessage leaveGame];
        [menuViewController.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (NSString *)menuViewControllerTitle:(JSKMenuViewController *)menuViewController
{
    NSString *title = NSLocalizedString(@"Game Over", @"Game Over  --  title");
    return title;
}

- (NSInteger)menuViewControllerNumberOfSections:(JSKMenuViewController *)menuViewController
{
    return GameOverSection_MaxValue;
}

- (NSInteger)menuViewController:(JSKMenuViewController *)menuViewController numberOfRowsInSection:(NSInteger)section
{
    NSInteger returnValue = 0;
    GameOverSection menuSection = (GameOverSection)section;
    switch (menuSection)
    {
        case GameOverSectionSummary:
            returnValue = GameOverSummaryRow_MaxValue;
            break;
            
        case GameOverSectionCommand:
            returnValue = 1;
            break;
            
        case GameOverSection_MaxValue:
            break;
    }
    return returnValue;
}

- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController titleForHeaderInSection:(NSInteger)section
{
    NSString *returnValue = nil;
    GameOverSection menuSection = (GameOverSection)section;
    switch (menuSection)
    {
        case GameOverSectionSummary:
            returnValue = NSLocalizedString(@"Summary", @"Summary  --  title");
            break;
            
        case GameOverSectionCommand:
            break;
            
        case GameOverSection_MaxValue:
            break;
    }
    return returnValue;
}

- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController labelAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *returnValue = nil;
    GameOverSection menuSection = (GameOverSection)indexPath.section;
    switch (menuSection)
    {
        case GameOverSectionSummary:
        {
            GameOverSummaryRow menuRow = (GameOverSummaryRow)indexPath.row;
            switch (menuRow)
            {
                case GameOverSummaryRowResult:
                    
                    break;
                    
                case GameOverSummaryRowReason:
                    
                    break;
                    
                case GameOverSummaryRow_MaxValue:
                    break;
            }
            break;
        }
            
        case GameOverSectionCommand:
            returnValue = NSLocalizedString(@"Dismiss", @"Dismiss  --  label");
            break;
            
        case GameOverSection_MaxValue:
            break;
    }
    return returnValue;
}

- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController subLabelAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *returnValue = nil;
    GameOverSection menuSection = (GameOverSection)indexPath.section;
    switch (menuSection)
    {
        case GameOverSectionSummary:
        {
            GameOverSummaryRow menuRow = (GameOverSummaryRow)indexPath.row;
            switch (menuRow)
            {
                case GameOverSummaryRowResult:
                    
                    break;
                    
                case GameOverSummaryRowReason:
                    
                    break;
                    
                case GameOverSummaryRow_MaxValue:
                    break;
            }
            break;
        }
            
        case GameOverSectionCommand:
            returnValue = NSLocalizedString(@"Tap to leave the game.", @"Tap to leave the game.  --  sub label");
            break;
            
        case GameOverSection_MaxValue:
            break;
    }
    return returnValue;
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
