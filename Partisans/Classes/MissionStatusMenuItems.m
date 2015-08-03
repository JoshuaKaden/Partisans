//
//  MissionStatusMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 7/8/13.
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

#import "MissionStatusMenuItems.h"

#import "DossierDelegate.h"
#import "DossierViewController.h"
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
@property (nonatomic, strong) DossierDelegate *dossierDelegate;

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
@synthesize dossierDelegate = m_dossierDelegate;


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.pollingTimer invalidate];
    
    
}


- (void)gameChanged:(NSNotification *)notification
{
    // This update could mean the end of the current mission.
    GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
    if (self.thisMissionNumber > 0 && self.thisMissionNumber < [gameEnvoy currentMission].missionNumber)
    {
        self.hasNewRoundStarted = YES;
    }
    
    if (gameEnvoy.endDate)
    {
        self.hasNewRoundStarted = YES;
    }
    
    self.currentMission = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:JSKMenuViewControllerShouldRefresh object:nil];
}


- (MissionEnvoy *)currentMission
{
    if (!m_currentMission)
    {
        GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
        if (self.thisMissionNumber > 0)
        {
            self.currentMission = [gameEnvoy missionEnvoyFromNumber:self.thisMissionNumber];
        }
        else
        {
            MissionEnvoy *currentMission = [[SystemMessage gameEnvoy] currentMission];
            self.currentMission = currentMission;
            self.thisMissionNumber = currentMission.missionNumber;
        }
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
    // Stop polling if a new round has started.
    if (self.hasNewRoundStarted)
    {
        [self.pollingTimer invalidate];
    }
    else
    {
        [SystemMessage requestGameUpdate];
    }
}


#pragma mark - Menu View Controller delegate


- (void)menuViewControllerDidLoad:(JSKMenuViewController *)menuViewController
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameChanged:) name:kPartisansNotificationGameChanged object:nil];
    self.menuViewController = menuViewController;
    
    // This timer polls the host for game changes.
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(pollingTimerFired:) userInfo:nil repeats:YES];
    self.pollingTimer = timer;
}

- (void)menuViewController:(JSKMenuViewController *)menuViewController willDisappear:(BOOL)animated
{
    [self.pollingTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.currentMission = nil;
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
    
    MissionEnvoy *missionEnvoy = self.currentMission;
    
    if (missionEnvoy.isComplete)
    {
        if ([SystemMessage isHost])
        {
            [self startNewRound];
            [menuViewController.navigationController popToRootViewControllerAnimated:YES];
        }
        else if (self.hasNewRoundStarted || [SystemMessage gameEnvoy].endDate)
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
                    returnValue = NSLocalizedString(@"Sabotage!", @"Sabotage!  --  label");
                }
            }
            else
            {
                returnValue = NSLocalizedString(@"In progress...", @"In progress...  --  label");
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
                    if (self.hasNewRoundStarted || [SystemMessage gameEnvoy].endDate)
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
        returnValue = playerEnvoy.smallImage;
    }
    return returnValue;
}

- (UIFont *)menuViewController:(JSKMenuViewController *)menuViewController labelFontAtIndexPath:(NSIndexPath *)indexPath
{
    UIFont *returnValue = nil;
    if (indexPath.section == MissionStatusSectionStatus)
    {
        MissionEnvoy *mission = self.currentMission;
        if (mission.isComplete)
        {
            returnValue = [UIFont fontWithName:@"GillSans-Bold" size:18.0f];
        }
    }
    return returnValue;
}

- (Class)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerClassAtIndexPath:(NSIndexPath *)indexPath
{
    Class returnValue = nil;
    
    if (indexPath.section == MissionStatusSectionTeam)
    {
        returnValue = [DossierViewController class];
    }
    
    return returnValue;
}

- (id)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerDelegateAtIndexPath:(NSIndexPath *)indexPath
{
    id returnValue = nil;
    if (indexPath.section == MissionStatusSectionTeam)
    {
        PlayerEnvoy *playerEnvoy = [self.currentMission.teamMembers objectAtIndex:indexPath.row];
        DossierDelegate *delegate = [[DossierDelegate alloc] initWithPlayerEnvoy:playerEnvoy];
        self.dossierDelegate = delegate;
        returnValue = self.dossierDelegate;
    }
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
    UITableViewCellAccessoryType returnValue = UITableViewCellAccessoryNone;
    
    if (indexPath.section == MissionStatusSectionStatus)
    {
        MissionEnvoy *mission = self.currentMission;
        if (mission.isComplete)
        {
            if ([SystemMessage isHost])
            {
                returnValue = UITableViewCellAccessoryDisclosureIndicator;
            }
            else if (self.hasNewRoundStarted || [SystemMessage gameEnvoy].endDate)
            {
                returnValue = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
    }
    else if (indexPath.section == MissionStatusSectionTeam)
    {
        returnValue = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return returnValue;
}

@end
