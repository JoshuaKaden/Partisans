//
//  MainMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 4/19/13.
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

#import "MainMenuItems.h"

#import "AboutMenuItems.h"
#import "DossiersMenuItems.h"
#import "GameEnvoy.h"
#import "GameOverMenuItems.h"
#import "GamePlayerEnvoy.h"
#import "MissionEnvoy.h"
#import "MissionStatusMenuItems.h"
#import "MissionViewController.h"
#import "OperativeAlertMenuItems.h"
#import "PlayerEnvoy.h"
#import "RoundEnvoy.h"
#import "RoundMenuItems.h"
#import "PlayerViewController.h"
#import "PlayGameMenuItems.h"
#import "ScoreViewController.h"
#import "SetupGameMenuItems.h"
#import "SystemMessage.h"


@interface MainMenuItems ()

@property (nonatomic, strong) MissionStatusMenuItems *missionStatusMenuItems;
@property (nonatomic, strong) PlayGameMenuItems *playGameMenuItems;
@property (nonatomic, strong) SetupGameMenuItems *setupGameMenuItems;
@property (nonatomic, strong) GameOverMenuItems *gameOverMenuItems;
@property (nonatomic, strong) DossiersMenuItems *dossiersMenuItems;
@property (nonatomic, strong) AboutMenuItems *aboutMenuItems;

@end


@implementation MainMenuItems

@synthesize missionStatusMenuItems = m_missionStatusMenuItems;
@synthesize playGameMenuItems = m_playGameMenuItems;
@synthesize setupGameMenuItems = m_setupGameMenuItems;
@synthesize gameOverMenuItems = m_gameOverMenuItems;
@synthesize dossiersMenuItems = m_dossiersMenuItems;
@synthesize aboutMenuItems = m_aboutMenuItems;



- (void)menuViewControllerDidLoad:(JSKMenuViewController *)menuViewController
{
    // Are we in a game?
    if ([SystemMessage gameEnvoy])
    {
        GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
        
        JSKMenuViewController *vc = [[JSKMenuViewController alloc] init];
        BOOL shouldPushMenuVC = YES;
        
        if (gameEnvoy.endDate)
        {
            // The game is over.
            GameOverMenuItems *items = [[GameOverMenuItems alloc] init];
            self.gameOverMenuItems = items;
            [vc setMenuItems:items];
        }
        
        else if (gameEnvoy.startDate)
        {
            // The game has started.
            PlayerEnvoy *playerEnvoy = [SystemMessage playerEnvoy];
            GamePlayerEnvoy *gamePlayerEnvoy = [gameEnvoy gamePlayerEnvoyFromPlayer:playerEnvoy];
            RoundEnvoy *currentRound = [gameEnvoy currentRound];
            MissionEnvoy *missionEnvoy = [gameEnvoy currentMission];
            
            // Is a mission in progress?
            if (missionEnvoy.hasStarted)
            {
                // Is this player on this mission's team?
                if (([missionEnvoy isPlayerOnTeam:playerEnvoy]) && (![missionEnvoy hasPlayerPerformed:playerEnvoy]))
                {
                    // Go to the Perform Mission screen.
                    MissionViewController *realVC = [[MissionViewController alloc] init];
                    [menuViewController invokePush:YES viewController:realVC];
                    shouldPushMenuVC = NO;
                }
                else
                {
                    // Go to the Mission Status screen.
                    MissionStatusMenuItems *items = [[MissionStatusMenuItems alloc] init];
                    self.missionStatusMenuItems = items;
                    [vc setMenuItems:items];
                }
            }
            
            // Should we show the Round Screen, or the Operative Alert screen?
            // The former if we've shown the latter.
            // Or, since we aren't saving that flag between sessions, if we've finished round 1.
            // ?? Or, if some candidates have been selected? What is the logic here?
            else if (gamePlayerEnvoy.hasAlertBeenShown || currentRound.roundNumber > 1 || currentRound.candidates.count > 0)
            {
                if ([currentRound hasPlayerVoted:playerEnvoy])
                {
                    gameEnvoy.hasScoreBeenShown = YES;
                }
                
                
                // Has the score already been shown?
                if (gameEnvoy.hasScoreBeenShown)
                {
                    // Show the Round Screen.
                    RoundMenuItems *items = [[RoundMenuItems alloc] init];
                    [vc setMenuItems:items];
                }
                else
                {
                    // Show the Score Screen.
                    ScoreViewController *realVC = [[ScoreViewController alloc] init];
                    [menuViewController invokePush:YES viewController:realVC];
                    shouldPushMenuVC = NO;
                }
                
            }
            else
            {
                OperativeAlertMenuItems *items = [[OperativeAlertMenuItems alloc] init];
                [vc setMenuItems:items];
            }
        }
        
        else
        {
            // Let's go to the setup screen.
            SetupGameMenuItems *items = [[SetupGameMenuItems alloc] init];
            self.setupGameMenuItems = items;
            [vc setMenuItems:items];
        }
        
        if (shouldPushMenuVC)
        {
            [menuViewController invokePush:YES viewController:vc];
        }
    }
}


- (NSString *)menuViewControllerTitle:(JSKMenuViewController *)menuViewController
{
    return NSLocalizedString(@"Partisans", @"Partisans  --  title");
}


- (BOOL)menuViewControllerHidesBackButton:(JSKMenuViewController *)menuViewController
{
    return YES;
}

- (BOOL)menuViewControllerHidesRefreshButton:(JSKMenuViewController *)menuViewController
{
    return YES;
}

- (BOOL)menuViewControllerShouldAutoRefresh:(JSKMenuViewController *)menuViewController
{
    return YES;
}


- (NSInteger)menuViewControllerNumberOfSections:(JSKMenuViewController *)menuViewController
{
    return 1;
}


- (NSInteger)menuViewController:(JSKMenuViewController *)menuViewController numberOfRowsInSection:(NSInteger)section
{
    if ([SystemMessage gameEnvoy].startDate)
    {
        return MainMenuRow_MaxValue;
    }
    else
    {
        // No Dossiers menu row if the game hasn't started.
        return MainMenuRow_MaxValue - 1;
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
        case MainMenuRowPlayer:
            label = NSLocalizedString(@"Player", @"Player  --  menu label");
            break;

        case MainMenuRowGame:
            label = NSLocalizedString(@"Game", @"Game  --  menu label");
            break;
            
        case MainMenuRowAbout:
            label = NSLocalizedString(@"About", @"About  --  menu label");
            break;
            
        case MainMenuRowDossiers:
            label = NSLocalizedString(@"Dossiers", @"Dossiers  -- menu label");
            break;
            
        case MainMenuRow_MaxValue:
            break;
    }
    
    return label;
}


- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController subLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section > 0)
    {
        return nil;
    }
    
    NSString *label = nil;
    
    switch (indexPath.row)
    {
        case MainMenuRowPlayer:
            label = [SystemMessage playerEnvoy].playerName;
            break;

        case MainMenuRowGame:
            break;
            
        case MainMenuRowAbout:
            break;

        case MainMenuRowDossiers:
            break;
            
        case MainMenuRow_MaxValue:
            break;
    }
    
    return label;
}

- (UIImage *)menuViewController:(JSKMenuViewController *)menuViewController imageForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == MainMenuRowPlayer)
    {
        return [SystemMessage playerEnvoy].smallImage;
    }
    else
    {
        return nil;
    }
}


- (Class)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerClassAtIndexPath:(NSIndexPath *)indexPath
{
    Class targetClass = nil;
    
    switch (indexPath.row)
    {
        case MainMenuRowPlayer:
            targetClass = [PlayerViewController class];
            break;
        
        case MainMenuRowGame:
            if ([SystemMessage gameEnvoy].startDate)
            {
                targetClass = [ScoreViewController class];
            }
            else
            {
                targetClass = [JSKMenuViewController class];
            }
            break;
            
        case MainMenuRowAbout:
            targetClass = [JSKMenuViewController class];
            break;
            
        case MainMenuRowDossiers:
            targetClass = [JSKMenuViewController class];
            break;
            
        case MainMenuRow_MaxValue:
            break;
    }
    
    return targetClass;
}


- (id)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerDelegateAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case MainMenuRowGame:
        {
            GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
            if (gameEnvoy)
            {
                if (gameEnvoy.startDate)
                {
                    return nil;
                }
                else
                {
                    SetupGameMenuItems *items = [[SetupGameMenuItems alloc] init];
                    self.setupGameMenuItems = items;
                    return self.setupGameMenuItems;
                }
            }
            else
            {
                PlayGameMenuItems *items = [[PlayGameMenuItems alloc] init];
                self.playGameMenuItems = items;
                return self.playGameMenuItems;
            }
            break;
        }
            
        case MainMenuRowAbout:
        {
            AboutMenuItems *items = [[AboutMenuItems alloc] init];
            self.aboutMenuItems = items;
            return self.aboutMenuItems;
            break;
        }
            
        case MainMenuRowDossiers:
        {
            DossiersMenuItems *items = [[DossiersMenuItems alloc] init];
            self.dossiersMenuItems = items;
            return self.dossiersMenuItems;
            break;
        }
            
        case MainMenuRow_MaxValue:
            return nil;
            break;
    }
    
    return nil;
}

@end
