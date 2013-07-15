//
//  GameOverMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 7/13/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "GameOverMenuItems.h"

#import "GameEnvoy.h"
#import "MissionEnvoy.h"
#import "SystemMessage.h"



@interface GameOverMenuItems ()

- (NSString *)reasonLabel;
- (NSString *)reasonSubLabel;

@end


@implementation GameOverMenuItems


- (NSString *)reasonLabel
{
    NSString *returnValue = nil;
    GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
    NSUInteger successfulMissionCount = [gameEnvoy successfulMissionCount];
    NSUInteger failedMissionCount = [gameEnvoy failedMissionCount];
    
    if (successfulMissionCount > 2)
    {
        returnValue = NSLocalizedString(@"Mission Success", @"Mission Success  --  label");
    }
    else if (failedMissionCount > 2)
    {
        returnValue = NSLocalizedString(@"Sabotage", @"Sabotage  --  label");
    }
    else
    {
        returnValue = NSLocalizedString(@"Deadlock", @"Deadlock  --  label");
    }
    
    return returnValue;
}

- (NSString *)reasonSubLabel
{
    NSString *returnValue = nil;
    GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
    NSUInteger successfulMissionCount = [gameEnvoy successfulMissionCount];
    NSUInteger failedMissionCount = [gameEnvoy failedMissionCount];
    
    if (successfulMissionCount > 2)
    {
        NSString *prefix = NSLocalizedString(@"The group successfully completed", @"The group successfully completed  --  label prefix");
        NSString *numberString = [SystemMessage spellOutInteger:successfulMissionCount];
        NSString *suffix = NSLocalizedString(@"missions.", @"missions.  --  label suffix");
        returnValue = [NSString stringWithFormat:@"%@ %@ %@", prefix, numberString, suffix];
    }
    else if (failedMissionCount > 2)
    {
        NSString *prefix = NSLocalizedString(@"The Operatives sabotaged", @"The Operatives sabotaged  --  label prefix");
        NSString *numberString = [SystemMessage spellOutInteger:failedMissionCount];
        NSString *suffix = NSLocalizedString(@"missions.", @"missions.  --  label suffix");
        returnValue = [NSString stringWithFormat:@"%@ %@ %@", prefix, numberString, suffix];
    }
    else
    {
        returnValue = NSLocalizedString(@"The group was unable to reach a consensus during team selection.", @"The group was unable to reach a consensus during team selection.  --  label");
    }
    
    return returnValue;
}


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
    GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
    GameOverSection menuSection = (GameOverSection)indexPath.section;
    switch (menuSection)
    {
        case GameOverSectionSummary:
        {
            GameOverSummaryRow menuRow = (GameOverSummaryRow)indexPath.row;
            switch (menuRow)
            {
                case GameOverSummaryRowResult:
                    if ([gameEnvoy successfulMissionCount] > 2)
                    {
                        returnValue = NSLocalizedString(@"Victory for the Partisans!", @"Victory for the Partisans!  --  label");
                    }
                    else
                    {
                        returnValue = NSLocalizedString(@"Victory for the Operatives!", @"Victory for the Operatives!  --  label");
                    }
                    break;
                    
                case GameOverSummaryRowReason:
                    returnValue = [self reasonLabel];
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
                    returnValue = [self reasonSubLabel];
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
