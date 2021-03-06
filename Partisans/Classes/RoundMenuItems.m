//
//  PlayerRoundMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 6/25/13.
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

#import "RoundMenuItems.h"

#import "CandidatePickerMenuItems.h"
#import "DecisionMenuItems.h"
#import "DossierDelegate.h"
#import "DossierViewController.h"
#import "GameEnvoy.h"
#import "ImageEnvoy.h"
#import "MissionEnvoy.h"
#import "NetworkManager.h"
#import "PlayerEnvoy.h"
#import "RoundEnvoy.h"
#import "SystemMessage.h"
#import "VoteEnvoy.h"
#import "VoteViewController.h"


@interface RoundMenuItems ()

@property (nonatomic, strong) GameEnvoy *gameEnvoy;
@property (nonatomic, strong) RoundEnvoy *currentRound;
@property (nonatomic, strong) MissionEnvoy *currentMission;
@property (nonatomic, strong) NSArray *candidates;
@property (nonatomic, strong) CandidatePickerMenuItems *candidatePickerMenuItems;
@property (nonatomic, strong) JSKMenuViewController *menuViewController;
@property (nonatomic, strong) NSString *responseKey;
@property (nonatomic, strong) DecisionMenuItems *decisionMenuItems;
@property (nonatomic, strong) NSTimer *pollingTimer;
@property (nonatomic, strong) DossierDelegate *dossierDelegate;

- (BOOL)isReadyForVote;
- (BOOL)isCoordinator;
- (void)gameChanged:(NSNotification *)notification;
- (void)playerUpdated:(NSNotification *)notification;
- (BOOL)hasVoted;

@end


@implementation RoundMenuItems

@synthesize gameEnvoy = m_gameEnvoy;
@synthesize currentRound = m_currentRound;
@synthesize currentMission = m_currentMission;
@synthesize candidates = m_candidates;
@synthesize candidatePickerMenuItems = m_candidatePickerMenuItems;
@synthesize menuViewController = m_menuViewController;
@synthesize responseKey = m_responseKey;
@synthesize decisionMenuItems = m_decisionMenuItems;
@synthesize pollingTimer = m_pollingTimer;
@synthesize dossierDelegate = m_dossierDelegate;


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.pollingTimer invalidate];
    
    
}

- (CandidatePickerMenuItems *)candidatePickerMenuItems
{
    if (!m_candidatePickerMenuItems)
    {
        CandidatePickerMenuItems *items = [[CandidatePickerMenuItems alloc] init];
        self.candidatePickerMenuItems = items;
    }
    return m_candidatePickerMenuItems;
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
    self.candidates = [self.currentRound candidates];
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

- (BOOL)isCoordinator
{
    if ([self.currentRound.coordinatorID isEqualToString:[SystemMessage playerEnvoy].intramuralID])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)isVotingComplete
{
    if (self.currentRound.votes.count == self.gameEnvoy.numberOfPlayers)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)hasVoted
{
    return [self.currentRound hasPlayerVoted:nil];
//    BOOL returnValue = NO;
//    PlayerEnvoy *playerEnvoy = [SystemMessage playerEnvoy];
//    for (VoteEnvoy *voteEnvoy in self.currentRound.votes)
//    {
//        if ([voteEnvoy.playerID isEqualToString:playerEnvoy.intramuralID])
//        {
//            returnValue = YES;
//            break;
//        }
//    }
//    return returnValue;
}




- (void)gameChanged:(NSNotification *)notification
{
    self.gameEnvoy = nil;
    self.currentRound = nil;
    self.currentMission = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:JSKMenuViewControllerShouldRefresh object:nil];
}

- (void)playerUpdated:(NSNotification *)notification
{
    self.gameEnvoy = nil;
    self.currentRound = nil;
    self.currentMission = nil;
}


#pragma mark - Polling Timer

- (void)pollingTimerFired:(id)sender
{
    // Stop polling if we're ready for a vote.
    if ([self isReadyForVote] || [self hasVoted])
    {
        [self.pollingTimer invalidate];
        [[NSNotificationCenter defaultCenter] postNotificationName:JSKMenuViewControllerShouldRefresh object:nil];
    }
    else
    {
        [SystemMessage requestGameUpdate];
    }
}




#pragma mark - Menu View Controller delegate



- (void)menuViewControllerDidLoad:(JSKMenuViewController *)menuViewController
{
    [NetworkManager putPlayerOnline];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameChanged:) name:kPartisansNotificationGameChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerUpdated:) name:kJSKNotificationPeerUpdated object:nil];

    // This timer polls the host for game changes.
    if (![self isReadyForVote])
    {
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(pollingTimerFired:) userInfo:nil repeats:YES];
        self.pollingTimer = timer;
    }
}


- (void)menuViewControllerInvokedRefresh:(JSKMenuViewController *)menuViewController
{
    // Force a reload of our local references.
    self.gameEnvoy = nil;
    self.currentRound = nil;
    self.currentMission = nil;
    [SystemMessage requestGameUpdate];
}


- (void)menuViewController:(JSKMenuViewController *)menuViewController didSelectRowAt:(NSIndexPath *)indexPath
{
//    if (indexPath.section == RoundMenuSectionCommand)
//    {
//        if ([self hasVoted])
//        {
//            return;
//        }
//        else if ([self isReadyForVote])
//        {
//            // Voting.
//            BOOL vote = YES;
//            if (indexPath.row == 1)
//            {
//                vote = NO;
//            }
//            
//            if ([SystemMessage isHost])
//            {
//                [self voteLocally:vote];
//                return;
//            }
//            
//            // Stash a reference to the menuViewController, so we can push the results screen when
//            // the host acknowledges our vote.
//            self.menuViewController = menuViewController;
//            [self connectAndVote:vote];
//            return;
//        }
//        else
//        {
////            if ([self isCoordinator])
////            {
////                JSKMenuViewController *vc = [[JSKMenuViewController alloc] init];
////                [vc setDelegate:self.candidatePickerMenuItems];
////                [menuViewController invokePush:YES viewController:vc];
////                [vc release];
////            }
//        }
//    }
//    
////    // Allow the coordinator to undo choices.
////    if (indexPath.section == RoundMenuSectionTeam)
////    {
////        if ([self isCoordinator])
////        {
////            JSKMenuViewController *vc = [[JSKMenuViewController alloc] init];
////            [vc setDelegate:self.candidatePickerMenuItems];
////            [menuViewController invokePush:YES viewController:vc];
////            [vc release];
////        }
////    }
}

- (NSString *)menuViewControllerTitle:(JSKMenuViewController *)menuViewController
{
    NSString *titlePrefix = NSLocalizedString(@"Round", @"Round  --  prefix");
    NSString *spelledNumber = [SystemMessage spellOutNumber:[NSNumber numberWithUnsignedInteger:self.currentRound.roundNumber]];
    NSString *title = [NSString stringWithFormat:@"%@ %@", titlePrefix, [spelledNumber capitalizedString]];
    return title;
}

- (NSInteger)menuViewControllerNumberOfSections:(JSKMenuViewController *)menuViewController
{
    return RoundMenuSection_MaxValue;
}

- (NSInteger)menuViewController:(JSKMenuViewController *)menuViewController numberOfRowsInSection:(NSInteger)section
{
    NSInteger returnValue = 0;
    RoundMenuSection menuSection = (RoundMenuSection)section;
    switch (menuSection)
    {
        case RoundMenuSectionMission:
            returnValue = RoundMenuMissionRow_MaxValue;
            break;
            
        case RoundMenuSectionTeam:
            returnValue = self.candidates.count;
            break;
            
        case RoundMenuSectionCommand:
            if ([self hasVoted])
            {
                // Let the user navigate to the Decision screen.
                returnValue = 1;
            }
            else if ([self isReadyForVote])
            {
                returnValue = 1;
//                // Two possible votes: YES and NO.
//                returnValue = 2;
            }
            else
            {
                if ([self isCoordinator])
                {
                    // One possible commands: Select Candidates.
                    returnValue = 1;
                }
                else
                {
                    // Nothing to do but save his life; call his wife in.
                    returnValue = 0;
                }
            }
            break;
            
        case RoundMenuSection_MaxValue:
            break;
    }
    return returnValue;
}

- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController titleForHeaderInSection:(NSInteger)section
{
    NSString *returnValue = nil;
    RoundMenuSection menuSection = (RoundMenuSection)section;
    switch (menuSection)
    {
        case RoundMenuSectionMission:
        {
            NSString *prefix = NSLocalizedString(@"Mission", @"Mission  --  title");
            NSString *spelledNumber = [SystemMessage spellOutNumber:[NSNumber numberWithUnsignedInteger:self.currentMission.missionNumber]];
            returnValue = [NSString stringWithFormat:@"%@ %@", prefix, [spelledNumber capitalizedString]];
            break;
        }
        case RoundMenuSectionTeam:
            if (self.candidates.count > 0)
            {
                returnValue = NSLocalizedString(@"Team Candidates", @"Team Candidates  --  title");
            }
            break;
        case RoundMenuSectionCommand:
            if ([self isVotingComplete])
            {
                returnValue = NSLocalizedString(@"Voting Complete", @"Voting Complete  --  title");
            }
            else if ([self hasVoted])
            {
                returnValue = NSLocalizedString(@"Voting in Progress", @"Voting in Progress  --  title");
            }
            else if ([self isReadyForVote])
            {
                NSUInteger roundCount = [self.currentMission roundCount];
                NSUInteger roundsToDeadlock = self.gameEnvoy.numberOfPlayers - roundCount;
                switch (roundsToDeadlock)
                {
                    case 0:
                        returnValue = NSLocalizedString(@"Vote (deadlock imminent!)", @"Vote (deadlock imminent!)  --  title");
                        break;
                    case 1:
                        returnValue = NSLocalizedString(@"Vote (deadlock in 2 rounds)", @"Vote (deadlock in 2 rounds)  --  title");
                        break;
                    default:
                        returnValue = NSLocalizedString(@"Vote", @"Vote  --  title");
                        break;
                }
            }
            else
            {
                if ([self isCoordinator])
                {
                    returnValue = NSLocalizedString(@"Team Selection", @"Team Selection  --  title");
                }
                else
                {
                    returnValue = NSLocalizedString(@"Waiting for Coordinator...", @"Waiting for Coordinator...  --  title");
                }
            }
            break;
        case RoundMenuSection_MaxValue:
            break;
    }
    return returnValue;
}

- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController labelAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *returnValue = nil;
    RoundMenuSection menuSection = (RoundMenuSection)indexPath.section;
    switch (menuSection)
    {
        case RoundMenuSectionMission:
        {
            RoundMenuMissionRow menuRow = (RoundMenuMissionRow)indexPath.row;
            switch (menuRow)
            {
                case RoundMenuMissionRowName:
                {
                    NSString *prefix = NSLocalizedString(@"Codename", @"Codename  --  label prefix");
                    returnValue = [NSString stringWithFormat:@"%@: %@", prefix, self.currentMission.missionName];
                    break;
                }
                    
                case RoundMenuMissionRowCoordinator:
                    if ([self isCoordinator])
                    {
                        returnValue = NSLocalizedString(@"You are the Coordinator", @"You are the Coordinator  --  label");
                    }
                    else
                    {
                        returnValue = self.currentRound.coordinator.playerName;
                    }
                    break;
                    
                case RoundMenuMissionRow_MaxValue:
                    break;
            }
            break;
        }
            
        case RoundMenuSectionTeam:
        {
            PlayerEnvoy *candidate = [self.candidates objectAtIndex:indexPath.row];
            returnValue = candidate.playerName;
            break;
        }
        
        case RoundMenuSectionCommand:
            if ([self isVotingComplete])
            {
                returnValue = NSLocalizedString(@"Decision", @"Decision  --  label");
            }
            else if ([self hasVoted])
            {
                returnValue = NSLocalizedString(@"Decision", @"Decision  --  label");
            }
            else if ([self isReadyForVote])
            {
                returnValue = NSLocalizedString(@"Voting Booth", @"Voting Booth  --  label");
//                if (indexPath.row == 0)
//                {
//                    returnValue = NSLocalizedString(@"Vote YES", @"Vote YES  --  label");
//                }
//                else
//                {
//                    returnValue = NSLocalizedString(@"Vote NO", @"Vote NO  --  label");
//                }
            }
            else
            {
                if ([self isCoordinator])
                {
                    returnValue = NSLocalizedString(@"Select Candidates", @"Select Candidates  --  label");
                }
            }
            break;
            
        case RoundMenuSection_MaxValue:
            break;
    }
    return returnValue;
}

- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController subLabelAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *returnValue = nil;
    if (indexPath.section == RoundMenuSectionMission)
    {
        if (indexPath.row == RoundMenuMissionRowCoordinator)
        {
            returnValue = NSLocalizedString(@"Mission Coordinator", @"Mission Coordinator  --  sublabel");
        }
        if (indexPath.row == RoundMenuMissionRowName)
        {
            NSString *prefix = NSLocalizedString(@"Requires", @"Requires  --  sublabel prefix");
            NSString *spelledNumber = [SystemMessage spellOutNumber:[NSNumber numberWithUnsignedInteger:self.currentMission.teamCount]];
            NSString *suffix = NSLocalizedString(@"team members", @"team members  --  sublabel suffix");
            returnValue = [NSString stringWithFormat:@"%@ %@ %@", prefix, spelledNumber, suffix];
        }
    }
    return returnValue;
}

- (UIImage *)menuViewController:(JSKMenuViewController *)menuViewController imageForIndexPath:(NSIndexPath *)indexPath
{
    UIImage *returnValue = nil;
    if (indexPath.section == RoundMenuSectionMission)
    {
        if (indexPath.row == RoundMenuMissionRowCoordinator)
        {
            returnValue = self.currentRound.coordinator.smallImage;
        }
    }
    else if (indexPath.section == RoundMenuSectionTeam)
    {
        PlayerEnvoy *candidate = [self.candidates objectAtIndex:indexPath.row];
        returnValue = candidate.smallImage;
    }
    return returnValue;
}

- (UIFont *)menuViewController:(JSKMenuViewController *)menuViewController labelFontAtIndexPath:(NSIndexPath *)indexPath
{
    UIFont *returnValue = nil;
    if (indexPath.section == RoundMenuSectionCommand)
    {
        if ([self isVotingComplete] || [self hasVoted] || [self isReadyForVote])
        {
            returnValue = [UIFont fontWithName:@"GillSans" size:25];
        }
    }
    return returnValue;
}

- (Class)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerClassAtIndexPath:(NSIndexPath *)indexPath
{
    Class returnValue = nil;
    
    // Allow coordinator to undo candidate selection.
    if (indexPath.section == RoundMenuSectionTeam)
    {
        if ([self isCoordinator] && ![self hasVoted])
        {
            returnValue = [JSKMenuViewController class];
        }
        else if ([self isReadyForVote])
        {
            returnValue = [DossierViewController class];
        }
    }
    
    if (indexPath.section == RoundMenuSectionCommand)
    {
        if ([self hasVoted])
        {
            returnValue = [JSKMenuViewController class];
        }
        else if ([self isReadyForVote])
        {
            returnValue = [VoteViewController class];
        }
        else if ([self isCoordinator] && ![self isReadyForVote])
        {
            returnValue = [JSKMenuViewController class];
        }
    }
    return returnValue;
}

- (id)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerDelegateAtIndexPath:(NSIndexPath *)indexPath
{
    id returnValue = nil;
    
    // Allow the coordinator to undo choices.
    if (indexPath.section == RoundMenuSectionTeam)
    {
        if ([self isCoordinator] && ![self hasVoted])
        {
            CandidatePickerMenuItems *items = [[CandidatePickerMenuItems alloc] init];
            self.candidatePickerMenuItems = items;
            returnValue = self.candidatePickerMenuItems;
        }
        else if ([self isReadyForVote])
        {
            PlayerEnvoy *playerEnvoy = [self.candidates objectAtIndex:indexPath.row];
            DossierDelegate *delegate = [[DossierDelegate alloc] initWithPlayerEnvoy:playerEnvoy];
            self.dossierDelegate = delegate;
            returnValue = self.dossierDelegate;
        }
    }
    
    if (indexPath.section == RoundMenuSectionCommand)
    {
        if ([self hasVoted])
        {
            DecisionMenuItems *items = [[DecisionMenuItems alloc] init];
            self.decisionMenuItems = items;
            returnValue = self.decisionMenuItems;
        }
        else if ([self isCoordinator] && ![self isReadyForVote])
        {
            CandidatePickerMenuItems *items = [[CandidatePickerMenuItems alloc] init];
            self.candidatePickerMenuItems = items;
            returnValue = self.candidatePickerMenuItems;
        }
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
    
    if (indexPath.section == RoundMenuSectionTeam)
    {
        if ([self isCoordinator] && ![self hasVoted])
        {
            returnValue = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if ([self isReadyForVote])
        {
            returnValue = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    if (indexPath.section == RoundMenuSectionCommand)
    {
        if ([self isReadyForVote])
        {
            returnValue = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if ([self isCoordinator] && ![self isReadyForVote])
        {
            returnValue = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if ([self hasVoted])
        {
            returnValue = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    return returnValue;
}

@end
