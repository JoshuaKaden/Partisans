//
//  MainMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 4/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "MainMenuItems.h"

#import "ImageEnvoy.h"
#import "PlayerEnvoy.h"
#import "PlayerViewController.h"
#import "PlayGameMenuItems.h"
#import "SetupGameMenuItems.h"
#import "SystemMessage.h"


@interface MainMenuItems ()

@property (nonatomic, strong) PlayGameMenuItems *playGameMenuItems;
@property (nonatomic, strong) SetupGameMenuItems *setupGameMenuItems;

@end


@implementation MainMenuItems

@synthesize playGameMenuItems = m_playGameMenuItems;
@synthesize setupGameMenuItems = m_setupGameMenuItems;


- (void)dealloc
{
    [m_playGameMenuItems release];
    [m_setupGameMenuItems release];
    
    [super dealloc];
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
            
        case MainMenuRowAccomplishments:
            label = NSLocalizedString(@"Accomplishments", @"Accomplishments  --  menu label");
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
        case MainMenuRowAccomplishments:
            break;
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
        case MainMenuRowAccomplishments:
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
        case MainMenuRowAccomplishments:
            return nil;
            
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
