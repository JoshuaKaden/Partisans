//
//  GameOverMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 7/13/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "GameOverMenuItems.h"

#import "DossierDelegate.h"
#import "DossierViewController.h"
#import "GameEnvoy.h"
#import "MissionEnvoy.h"
#import "PlayerEnvoy.h"
#import "SystemMessage.h"



@interface GameOverMenuItems ()

@property (nonatomic, strong) NSArray *players;
@property (nonatomic, strong) DossierDelegate *dossierDelegate;

- (NSString *)reasonLabel;
- (NSString *)reasonSubLabel;

@end


@implementation GameOverMenuItems

@synthesize players = m_players;
@synthesize dossierDelegate = m_dossierDelegate;


- (void)dealloc
{
    [m_players release];
    [m_dossierDelegate release];
    
    [super dealloc];
}


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
        NSString *prefix = NSLocalizedString(@"The group completed", @"The group completed  --  label prefix");
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
        returnValue = NSLocalizedString(@"You were unable to reach a consensus.", @"You were unable to reach a consensus.  --  label");
    }
    
    return returnValue;
}


#pragma mark - Menu View Controller delegate

- (void)menuViewControllerDidLoad:(JSKMenuViewController *)menuViewController
{
    self.players = [[SystemMessage gameEnvoy] players];
}

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
            
        case GameOverSectionPlayers:
            returnValue = self.players.count;
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
            
        case GameOverSectionPlayers:
            returnValue = NSLocalizedString(@"Players", @"Players  --  title");
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
            
        case GameOverSectionPlayers:
        {
            PlayerEnvoy *player = [self.players objectAtIndex:indexPath.row];
            returnValue = player.playerName;
            break;
        }
            
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
            
        case GameOverSectionPlayers:
            break;
            
        case GameOverSection_MaxValue:
            break;
    }
    return returnValue;
}

- (UIImage *)menuViewController:(JSKMenuViewController *)menuViewController imageForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == GameOverSectionPlayers)
    {
        PlayerEnvoy *playerEnvoy = [self.players objectAtIndex:indexPath.row];
        return playerEnvoy.smallImage;
    }
    else
    {
        return nil;
    }
}

- (Class)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerClassAtIndexPath:(NSIndexPath *)indexPath
{
    Class returnValue = nil;
    if (indexPath.section == GameOverSectionPlayers)
    {
        returnValue = [DossierViewController class];
    }
    return returnValue;
}

- (id)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerDelegateAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == GameOverSectionPlayers)
    {
        PlayerEnvoy *playerEnvoy = [self.players objectAtIndex:indexPath.row];
        DossierDelegate *delegate = [[DossierDelegate alloc] initWithPlayerEnvoy:playerEnvoy];
        self.dossierDelegate = delegate;
        [delegate release];
        return self.dossierDelegate;
    }
    else
    {
        return nil;
    }
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
    if (indexPath.section == GameOverSectionSummary)
    {
        return UITableViewCellAccessoryNone;
    }
    else
    {
        return UITableViewCellAccessoryDisclosureIndicator;
    }
}

@end
