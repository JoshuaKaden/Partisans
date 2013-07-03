//
//  MainMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 4/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "MainMenuItems.h"

#import "GameEnvoy.h"
#import "GamePlayerEnvoy.h"
#import "ImageEnvoy.h"
#import "OperativeAlertMenuItems.h"
#import "PlayerEnvoy.h"
#import "RoundEnvoy.h"
#import "RoundMenuItems.h"
#import "PlayerViewController.h"
#import "PlayGameMenuItems.h"
#import "SetupGameMenuItems.h"
#import "SystemMessage.h"
#import "ToolsMenuItems.h"


@interface MainMenuItems ()

@property (nonatomic, strong) PlayGameMenuItems *playGameMenuItems;
@property (nonatomic, strong) SetupGameMenuItems *setupGameMenuItems;
@property (nonatomic, strong) ToolsMenuItems *toolsMenuItems;

@end


@implementation MainMenuItems

@synthesize playGameMenuItems = m_playGameMenuItems;
@synthesize setupGameMenuItems = m_setupGameMenuItems;
@synthesize toolsMenuItems = m_toolsMenuItems;


- (void)dealloc
{
    [m_playGameMenuItems release];
    [m_setupGameMenuItems release];
    [m_toolsMenuItems release];
    
    [super dealloc];
}

- (void)menuViewControllerDidLoad:(JSKMenuViewController *)menuViewController
{
    // Are we in a game?
    if ([SystemMessage gameEnvoy])
    {
        JSKMenuViewController *vc = [[JSKMenuViewController alloc] init];
        if ([SystemMessage gameEnvoy].startDate)
        {
            // The game has started.
            PlayerEnvoy *playerEnvoy = [SystemMessage playerEnvoy];
            GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
            GamePlayerEnvoy *gamePlayerEnvoy = [gameEnvoy gamePlayerEnvoyFromPlayer:playerEnvoy];
            if (gamePlayerEnvoy.hasAlertBeenShown || [gameEnvoy currentRound].roundNumber > 1 || [gameEnvoy currentRound].candidates.count > 0)
            {
                RoundMenuItems *items = [[RoundMenuItems alloc] init];
                [vc setMenuItems:items];
                [items release];
            }
            else
            {
                OperativeAlertMenuItems *items = [[OperativeAlertMenuItems alloc] init];
                [vc setMenuItems:items];
                [items release];
            }
        }
        else
        {
            // Let's go to the setup screen.
            SetupGameMenuItems *items = [[SetupGameMenuItems alloc] init];
            self.setupGameMenuItems = items;
            [vc setMenuItems:items];
            [items release];
        }
        [menuViewController invokePush:YES viewController:vc];
        [vc release];
    }
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
    if (section == 0)
    {
        return MainMenuRow_MaxValue;
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
        case MainMenuRowPlayer:
            label = NSLocalizedString(@"Player", @"Player  --  menu label");
            break;

        case MainMenuRowGame:
            label = NSLocalizedString(@"Game", @"Game  --  menu label");
            break;
                        
        case MainMenuRowScores:
            label = NSLocalizedString(@"Scores", @"Scores  --  menu label");
            break;
            
        case MainMenuRowTools:
            label = NSLocalizedString(@"Tools", @"Tools  --  menu label");
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
            
        case MainMenuRowScores:
            break;
            
        case MainMenuRowTools:
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
        return [SystemMessage playerEnvoy].picture.image;
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
        case MainMenuRowScores:
        case MainMenuRowTools:
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
                SetupGameMenuItems *items = [[SetupGameMenuItems alloc] init];
                self.setupGameMenuItems = items;
                [items release];
                return self.setupGameMenuItems;
            }
            else
            {
                PlayGameMenuItems *items = [[PlayGameMenuItems alloc] init];
                self.playGameMenuItems = items;
                [items release];
                return self.playGameMenuItems;
            }
            break;
        }
            
        case MainMenuRowScores:
            return nil;
            break;
            
        case MainMenuRowTools:
        {
            ToolsMenuItems *items = [[ToolsMenuItems alloc] init];
            self.toolsMenuItems = items;
            [items release];
            return self.toolsMenuItems;
            break;
        }
            
        case MainMenuRow_MaxValue:
            return nil;
            break;
    }
    
    return nil;
}


- (NSString *)menuViewControllerTitle:(JSKMenuViewController *)menuViewController
{
    return NSLocalizedString(@"Partisans", @"Partisans  --  title");
}


- (BOOL)menuViewControllerHidesBackButton:(JSKMenuViewController *)menuViewController
{
    return YES;
}



@end
