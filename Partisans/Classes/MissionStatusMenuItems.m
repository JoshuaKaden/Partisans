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
@property (nonatomic, strong) NSTimer *pollingTimer;
@property (nonatomic, strong) JSKMenuViewController *menuViewController;
@property (nonatomic, assign) NSUInteger thisMissionNumber;
@property (nonatomic, assign) BOOL hasNewRoundStarted;

- (void)gameChanged:(NSNotification *)notification;
- (void)startNewRound;
- (void)pollingTimerFired:(id)sender;

@end


@implementation MissionStatusMenuItems

@synthesize currentMission = m_currentMission;
@synthesize pollingTimer = m_pollingTimer;
@synthesize menuViewController = m_menuViewController;
@synthesize thisMissionNumber = m_thisMissionNumber;
@synthesize hasNewRoundStarted = m_hasNewRoundStarted;


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.pollingTimer invalidate];
    
    [m_currentMission release];
    [m_pollingTimer release];
    [m_menuViewController release];
    
    [super dealloc];
}


- (void)gameChanged:(NSNotification *)notification
{
    // This update could mean the end of the current mission.
    GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
    if (self.thisMissionNumber < [gameEnvoy currentMission].missionNumber)
    {
        self.hasNewRoundStarted = YES;
    }
    self.currentMission = [gameEnvoy missionEnvoyFromNumber:self.thisMissionNumber];
    [[NSNotificationCenter defaultCenter] postNotificationName:JSKMenuViewControllerShouldRefresh object:nil];
}


- (MissionEnvoy *)currentMission
{
    if (!m_currentMission)
    {
        MissionEnvoy *currentMission = [[SystemMessage gameEnvoy] currentMission];
        self.currentMission = currentMission;
        self.thisMissionNumber = currentMission.missionNumber;
    }
    return m_currentMission;
}


- (void)startNewRound
{
    GameDirector *director = [SystemMessage gameDirector];
    [director startNewRound];
}


- (void)pollingTimerFired:(id)sender
{
    [SystemMessage requestGameUpdate];
}


#pragma mark - Menu View Controller delegate


- (void)menuViewControllerDidLoad:(JSKMenuViewController *)menuViewController
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameChanged:) name:kPartisansNotificationGameChanged object:nil];
    self.menuViewController = menuViewController;
    
//    // This timer polls the host for game changes.
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(pollingTimerFired:) userInfo:nil repeats:YES];
//    self.pollingTimer = timer;
}

- (void)menuViewControllerInvokedRefresh:(JSKMenuViewController *)menuViewController
{
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
        else if (self.hasNewRoundStarted)
        {
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
                    returnValue = NSLocalizedString(@"Tap to start a new round.", @"Tap to start a new round.  --  label");
                }
                else
                {
                    if (self.hasNewRoundStarted)
                    {
                        returnValue = NSLocalizedString(@"Tap to continue.", @"Tap to continue.  --  label");
                    }
                    else
                    {
                        returnValue = NSLocalizedString(@"Waiting for host...", @"Waiting for host...  --  label");
                    }
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
