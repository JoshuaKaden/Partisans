//
//  GameOverMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 7/13/13.
//
//  Copyright (c) 2013, Joshua Kaden
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
//  PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
        returnValue = NSLocalizedString(@"Mission Success!", @"Mission Success!  --  label");
    }
    else if (failedMissionCount > 2)
    {
        returnValue = NSLocalizedString(@"Sabotage!", @"Sabotage!  --  label");
    }
    else
    {
        returnValue = NSLocalizedString(@"Deadlock!", @"Deadlock!  --  label");
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
            returnValue = NSLocalizedString(@"Tap to end the game.", @"Tap to end the game.  --  sub label");
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
