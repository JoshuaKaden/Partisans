//
//  MissionStatusMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 7/8/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "MissionStatusMenuItems.h"

#import "GameDirector.h"
#import "GameEnvoy.h"
#import "ImageEnvoy.h"
#import "MissionEnvoy.h"
#import "PlayerEnvoy.h"
#import "RoundEnvoy.h"
#import "SystemMessage.h"


@interface MissionStatusMenuItems ()

@property (nonatomic, strong) MissionEnvoy *currentMission;
- (void)gameChanged:(NSNotification *)notification;
- (void)startNewRound;

@end


@implementation MissionStatusMenuItems

@synthesize currentMission = m_currentMission;


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [m_currentMission release];
    [super dealloc];
}


- (void)gameChanged:(NSNotification *)notification
{
    self.currentMission = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:JSKMenuViewControllerShouldRefresh object:nil];
}


- (MissionEnvoy *)currentMission
{
    if (!m_currentMission)
    {
        self.currentMission = [[SystemMessage gameEnvoy] currentMission];
    }
    return m_currentMission;
}


- (void)startNewRound
{
    GameDirector *director = [SystemMessage gameDirector];
    [director startNewRound];
}


#pragma mark - Menu View Controller delegate


- (void)menuViewControllerDidLoad:(JSKMenuViewController *)menuViewController
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameChanged:) name:kPartisansNotificationGameChanged object:nil];
}

- (void)menuViewControllerInvokedRefresh:(JSKMenuViewController *)menuViewController
{
    self.currentMission = nil;
    [SystemMessage requestGameUpdate];
}

- (void)menuViewController:(JSKMenuViewController *)menuViewController didSelectRowAt:(NSIndexPath *)indexPath
{
    if (!(indexPath.section == MissionStatusSectionStatus))
    {
        return;
    }
    
    MissionEnvoy *missionEnvoy = [self currentMission];
    
    if (missionEnvoy.isComplete)
    {
        if ([SystemMessage isHost])
        {
            [self startNewRound];
            [menuViewController.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}


- (NSString *)menuViewControllerTitle:(JSKMenuViewController *)menuViewController
{
    NSString *title = NSLocalizedString(@"Mission Status", @"Mission Status  --  title");
    return title;
}

- (NSInteger)menuViewControllerNumberOfSections:(JSKMenuViewController *)menuViewController
{
    return MissionStatusSection_MaxValue;
}

- (NSInteger)menuViewController:(JSKMenuViewController *)menuViewController numberOfRowsInSection:(NSInteger)section
{
    NSInteger returnValue = 0;
    
    MissionStatusSection menuSection = (MissionStatusSection)section;
    switch (menuSection)
    {
        case MissionStatusSectionStatus:
            returnValue = 1;
            break;
        case MissionStatusSectionTeam:
            returnValue = self.currentMission.teamCount;
            break;
        case MissionStatusSection_MaxValue:
            break;
    }
    return returnValue;
}

- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController titleForHeaderInSection:(NSInteger)section
{
    NSString *returnValue = nil;
    MissionStatusSection menuSection = (MissionStatusSection)section;
    switch (menuSection)
    {
        case MissionStatusSectionStatus:
            returnValue = NSLocalizedString(@"Status", @"Status  --  label");
            break;
        case MissionStatusSectionTeam:
            returnValue = NSLocalizedString(@"Team", @"Team  --  label");
            break;
        case MissionStatusSection_MaxValue:
            break;
    }
    return returnValue;
}


- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController labelAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *returnValue = nil;
    MissionEnvoy *missionEnvoy = self.currentMission;
    MissionStatusSection menuSection = (MissionStatusSection)indexPath.section;
    switch (menuSection)
    {
        case MissionStatusSectionStatus:
            if (missionEnvoy.isComplete)
            {
                if (missionEnvoy.didSucceed)
                {
                    returnValue = NSLocalizedString(@"SUCCESS!", @"SUCCESS!  --  label");
                }
                else
                {
                    returnValue = NSLocalizedString(@"Failed!", @"Failed!  --  label");
                }
            }
            else
            {
                returnValue = NSLocalizedString(@"In progress...", @"In progress  --  label");
            }
            break;
        case MissionStatusSectionTeam:
        {
            PlayerEnvoy *playerEnvoy = [missionEnvoy.teamMembers objectAtIndex:indexPath.row];
            returnValue = playerEnvoy.playerName;
            break;
        }
        case MissionStatusSection_MaxValue:
            break;
    }
    return returnValue;
}

- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController subLabelAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *returnValue = nil;
    MissionEnvoy *missionEnvoy = self.currentMission;
    MissionStatusSection menuSection = (MissionStatusSection)indexPath.section;
    switch (menuSection)
    {
        case MissionStatusSectionStatus:
            if (missionEnvoy.isComplete)
            {
                if ([SystemMessage isHost])
                {
                    returnValue = NSLocalizedString(@"Tap to start a new round...", @"Tap to start a new round...  --  label");
                }
                else
                {
                    returnValue = NSLocalizedString(@"Waiting for host...", @"Waiting for host...  --  label");
                }
            }
            break;
        case MissionStatusSectionTeam:
        {
//            PlayerEnvoy *playerEnvoy = [missionEnvoy.teamMembers objectAtIndex:indexPath.row];
//            returnValue = playerEnvoy.playerName;
            break;
        }
        case MissionStatusSection_MaxValue:
            break;
    }
    return returnValue;
}

- (UIImage *)menuViewController:(JSKMenuViewController *)menuViewController imageForIndexPath:(NSIndexPath *)indexPath
{
    UIImage *returnValue = nil;
    if (indexPath.section == MissionStatusSectionTeam)
    {
        PlayerEnvoy *playerEnvoy = [self.currentMission.teamMembers objectAtIndex:indexPath.row];
        returnValue = playerEnvoy.picture.image;
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
    return NO;
}

- (BOOL)menuViewControllerShouldAutoRefresh:(JSKMenuViewController *)menuViewController
{
    return YES;
}

- (UITableViewCellAccessoryType)menuViewController:(JSKMenuViewController *)menuViewController cellAccessoryTypeForIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellAccessoryNone;
}

@end
