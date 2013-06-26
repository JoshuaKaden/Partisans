//
//  PlayerRoundMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 6/25/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "PlayerRoundMenuItems.h"

#import "GameEnvoy.h"
#import "ImageEnvoy.h"
#import "MissionEnvoy.h"
#import "PlayerEnvoy.h"
#import "RoundEnvoy.h"
#import "SystemMessage.h"


@interface PlayerRoundMenuItems ()

@property (nonatomic, strong) GameEnvoy *gameEnvoy;
@property (nonatomic, strong) RoundEnvoy *currentRound;
@property (nonatomic, strong) MissionEnvoy *currentMission;
@property (nonatomic, strong) NSArray *candidates;

- (BOOL)isReadyForVote;

@end


@implementation PlayerRoundMenuItems

@synthesize gameEnvoy = m_gameEnvoy;
@synthesize currentRound = m_currentRound;
@synthesize currentMission = m_currentMission;
@synthesize candidates = m_candidates;


- (void)dealloc
{
    [m_gameEnvoy release];
    [m_currentRound release];
    [m_currentMission release];
    [m_candidates release];
    [super dealloc];
}

- (GameEnvoy *)gameEnvoy
{
    if (!m_gameEnvoy)
    {
        self.gameEnvoy = [SystemMessage gameEnvoy];
    }
    return m_gameEnvoy;
}

- (RoundEnvoy *)currentRound
{
    if (!m_currentRound)
    {
        self.currentRound = [self.gameEnvoy currentRound];
    }
    return m_currentRound;
}

- (MissionEnvoy *)currentMission
{
    if (!m_currentMission)
    {
        self.currentMission = [self.gameEnvoy currentMission];
    }
    return m_currentMission;
}

- (NSArray *)candidates
{
    if (!m_candidates)
    {
        self.candidates = [self.currentRound candidates];
    }
    return m_candidates;
}

- (BOOL)isReadyForVote
{
    if (self.candidates.count == self.currentMission.teamCount)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - Menu View Controller delegate

- (void)menuViewController:(JSKMenuViewController *)menuViewController didSelectRowAt:(NSIndexPath *)indexPath
{
    if (indexPath.section == PlayerRoundMenuSectionCommand)
    {
        // Voting
        
        
        
    }
}

- (NSString *)menuViewControllerTitle:(JSKMenuViewController *)menuViewController
{
    NSString *titlePrefix = NSLocalizedString(@"Round", @"Round  --  prefix");
    NSUInteger roundNumber = self.currentRound.roundNumber;
    NSString *title = [NSString stringWithFormat:@"%@ %d", titlePrefix, roundNumber];
    return title;
}

- (NSInteger)menuViewControllerNumberOfSections:(JSKMenuViewController *)menuViewController
{
    return PlayerRoundMenuSection_MaxValue;
}

- (NSInteger)menuViewController:(JSKMenuViewController *)menuViewController numberOfRowsInSection:(NSInteger)section
{
    NSInteger returnValue = 0;
    PlayerRoundMenuSection menuSection = (PlayerRoundMenuSection)section;
    switch (menuSection)
    {
        case PlayerRoundMenuSectionMission:
            returnValue = PlayerRoundMenuMissionRow_MaxValue;
            break;
            
        case PlayerRoundMenuSectionTeam:
            returnValue = self.candidates.count;
            break;
            
        case PlayerRoundMenuSectionCommand:
            if ([self isReadyForVote])
            {
                return 2;
            }
            else
            {
                return 0;
            }
            break;
            
        case PlayerRoundMenuSection_MaxValue:
            break;
    }
    return returnValue;
}

- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController titleForHeaderInSection:(NSInteger)section
{
    NSString *returnValue = nil;
    PlayerRoundMenuSection menuSection = (PlayerRoundMenuSection)section;
    switch (menuSection)
    {
        case PlayerRoundMenuSectionMission:
            returnValue = NSLocalizedString(@"Mission", @"Mission  --  title");
            break;
        case PlayerRoundMenuSectionTeam:
            returnValue = NSLocalizedString(@"Team Candidates", @"Team Candidates  --  title");
            break;
        case PlayerRoundMenuSectionCommand:
            if ([self isReadyForVote])
            {
                returnValue = NSLocalizedString(@"Ready for Vote", @"Ready for Vote  --  title");
            }
            else
            {
                returnValue = NSLocalizedString(@"Waiting for Coordinator", @"Waiting for Coordinator  --  title");
            }
            break;
        case PlayerRoundMenuSection_MaxValue:
            break;
    }
    return returnValue;
}

- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController labelAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *returnValue = nil;
    PlayerRoundMenuSection menuSection = (PlayerRoundMenuSection)indexPath.section;
    switch (menuSection)
    {
        case PlayerRoundMenuSectionMission:
        {
            PlayerRoundMenuMissionRow menuRow = (PlayerRoundMenuMissionRow)indexPath.row;
            switch (menuRow)
            {
                case PlayerRoundMenuMissionRowName:
                {
                    NSString *prefix = NSLocalizedString(@"Codename", @"Codename  --  label prefix");
                    returnValue = [NSString stringWithFormat:@"%@ %@", prefix, self.currentMission.missionName];
                    break;
                }
                    
                case PlayerRoundMenuMissionRowCoordinator:
                    returnValue = self.currentRound.coordinator.playerName;
                    break;
                    
                case PlayerRoundMenuMissionRow_MaxValue:
                    break;
            }
            break;
        }
            
        case PlayerRoundMenuSectionTeam:
        {
            PlayerEnvoy *candidate = [self.candidates objectAtIndex:indexPath.row];
            returnValue = candidate.playerName;
            break;
        }
        
        case PlayerRoundMenuSectionCommand:
            if ([self isReadyForVote])
            {
                if (indexPath.row == 0)
                {
                    returnValue = NSLocalizedString(@"Vote YES", @"Vote YES  --  label");
                }
                else
                {
                    returnValue = NSLocalizedString(@"Vote NO", @"Vote NO  --  label");
                }
            }
            break;
            
        case PlayerRoundMenuSection_MaxValue:
            break;
    }
    return returnValue;
}

- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController subLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == PlayerRoundMenuSectionMission)
    {
        if (indexPath.row == PlayerRoundMenuMissionRowCoordinator)
        {
            return NSLocalizedString(@"Mission Coordinator", @"Mission Coordinator  --  sublabel");
        }
        else
        {
            return nil;
        }
    }
    else
    {
        return nil;
    }
}

- (UIImage *)menuViewController:(JSKMenuViewController *)menuViewController imageForIndexPath:(NSIndexPath *)indexPath
{
    UIImage *returnValue = nil;
    if (indexPath.section == PlayerRoundMenuSectionMission)
    {
        if (indexPath.row == PlayerRoundMenuMissionRowCoordinator)
        {
            returnValue = self.currentRound.coordinator.picture.image;
        }
    }
    else if (indexPath.section == PlayerRoundMenuSectionTeam)
    {
        PlayerEnvoy *candidate = [self.candidates objectAtIndex:indexPath.row];
        returnValue = candidate.picture.image;
    }
    return returnValue;
}

- (Class)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerClassAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
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
    return NO;
}

- (UITableViewCellAccessoryType)menuViewController:(JSKMenuViewController *)menuViewController cellAccessoryTypeForIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellAccessoryNone;
}

@end
