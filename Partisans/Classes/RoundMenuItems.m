//
//  PlayerRoundMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 6/25/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "RoundMenuItems.h"

#import "CandidatePickerMenuItems.h"
#import "CoordinatorVote.h"
#import "DecisionMenuItems.h"
#import "GameEnvoy.h"
#import "HostFinder.h"
#import "ImageEnvoy.h"
#import "JSKOverlayer.h"
#import "MissionEnvoy.h"
#import "PlayerEnvoy.h"
#import "RoundEnvoy.h"
#import "SystemMessage.h"
#import "VoteEnvoy.h"


@interface RoundMenuItems () <HostFinderDelegate>

@property (nonatomic, strong) GameEnvoy *gameEnvoy;
@property (nonatomic, strong) RoundEnvoy *currentRound;
@property (nonatomic, strong) MissionEnvoy *currentMission;
@property (nonatomic, strong) NSArray *candidates;
@property (nonatomic, strong) CandidatePickerMenuItems *candidatePickerMenuItems;
@property (nonatomic, strong) JSKMenuViewController *menuViewController;
@property (nonatomic, strong) NSString *responseKey;
@property (nonatomic, strong) JSKOverlayer *overlayer;
@property (nonatomic, strong) DecisionMenuItems *decisionMenuItems;
@property (nonatomic, strong) HostFinder *hostFinder;
@property (nonatomic, strong) NSString *hostPeerID;
@property (nonatomic, assign) BOOL thisVote;

- (BOOL)isReadyForVote;
- (BOOL)isCoordinator;
- (void)voteLocally:(BOOL)vote;
- (void)connectAndVote:(BOOL)vote;
- (void)vote:(BOOL)vote;
- (void)hostAcknowledgement:(NSNotification *)notification;
- (BOOL)isVotingComplete;
- (void)goToDecisionScreen:(JSKMenuViewController *)menuViewController;
- (void)gameChanged:(NSNotification *)notification;

@end


@implementation RoundMenuItems

@synthesize gameEnvoy = m_gameEnvoy;
@synthesize currentRound = m_currentRound;
@synthesize currentMission = m_currentMission;
@synthesize candidates = m_candidates;
@synthesize candidatePickerMenuItems = m_candidatePickerMenuItems;
@synthesize menuViewController = m_menuViewController;
@synthesize responseKey = m_responseKey;
@synthesize overlayer = m_overlayer;
@synthesize decisionMenuItems = m_decisionMenuItems;
@synthesize hostFinder = m_hostFinder;
@synthesize hostPeerID = m_hostPeerID;
@synthesize thisVote = m_vote;


- (void)dealloc
{
    [self.hostFinder setDelegate:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [m_gameEnvoy release];
    [m_currentRound release];
    [m_currentMission release];
    [m_candidates release];
    [m_candidatePickerMenuItems release];
    [m_menuViewController release];
    [m_responseKey release];
    [m_overlayer release];
    [m_decisionMenuItems release];
    [m_hostFinder release];
    [m_hostPeerID release];
    
    [super dealloc];
}

- (CandidatePickerMenuItems *)candidatePickerMenuItems
{
    if (!m_candidatePickerMenuItems)
    {
        CandidatePickerMenuItems *items = [[CandidatePickerMenuItems alloc] init];
        self.candidatePickerMenuItems = items;
        [items release];
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



- (void)voteLocally:(BOOL)vote
{
    self.hostPeerID = [SystemMessage playerEnvoy].peerID;
    
    VoteEnvoy *voteEnvoy = [[VoteEnvoy alloc] init];
    voteEnvoy.isCast = YES;
    voteEnvoy.isYea = vote;
    voteEnvoy.roundID = self.currentRound.intramuralID;
    voteEnvoy.playerID = [SystemMessage playerEnvoy].intramuralID;
    [self.currentRound addVote:voteEnvoy];
    [voteEnvoy release];
    
    [self.gameEnvoy commitAndSave];
    
    if (![SystemMessage isPlayerOnline])
    {
        [SystemMessage putPlayerOnline];
    }
    JSKCommandParcel *parcel = [[JSKCommandParcel alloc] initWithType:JSKCommandParcelTypeUpdate to:nil from:self.hostPeerID object:self.gameEnvoy];
    [SystemMessage sendParcelToPlayers:parcel];
    [parcel release];
}


- (void)connectAndVote:(BOOL)vote
{
    if ([SystemMessage isHost])
    {
        [self vote:vote];
        return;
    }

    
    if (!self.overlayer)
    {
        JSKOverlayer *overlayer = [[JSKOverlayer alloc] initWithView:[SystemMessage rootView]];
        self.overlayer = overlayer;
        [overlayer release];
    }
    NSString *message = NSLocalizedString(@"Voting...", @"Voting...  --  message");
    [self.overlayer createWaitOverlayWithText:message];

    
    if ([SystemMessage isPlayerOnline])
    {
        self.hostPeerID = self.gameEnvoy.host.peerID;
        [self vote:vote];
        return;
    }
    
    if (!self.hostFinder)
    {
        HostFinder *hostFinder = [[HostFinder alloc] init];
        [hostFinder setDelegate:self];
        self.hostFinder = hostFinder;
        [hostFinder release];
    }
    [self.hostFinder connect];
    
    self.thisVote = vote;
}


- (void)vote:(BOOL)vote
{
    PlayerEnvoy *playerEnvoy = [SystemMessage playerEnvoy];
    
    // This involves sending a new (unconnected to core data) vote envoy to the host.
    // After the vote is acknowledged by the host, go to the results screen.
    // The host will update the game, and broadcast an update.
    
    NSObject <NSCoding> *parcelObject = nil;

    VoteEnvoy *voteEnvoy = [[VoteEnvoy alloc] init];
    voteEnvoy.isCast = NO;
    voteEnvoy.isYea = vote;
    voteEnvoy.roundID = self.currentRound.intramuralID;
    voteEnvoy.playerID = playerEnvoy.intramuralID;
    
    if ([self isCoordinator])
    {
        // The Coordinator has to send the team candidates to the host, along with the vote.
        CoordinatorVote *coordinatorVote = [[CoordinatorVote alloc] init];
        coordinatorVote.voteEnvoy = voteEnvoy;
        coordinatorVote.candidateIDs = [self.candidates valueForKey:@"intramuralID"];
        parcelObject = [coordinatorVote retain];
        [coordinatorVote release];
    }
    else
    {
        parcelObject = [voteEnvoy retain];
    }
    
    [voteEnvoy release];

    
    NSString *hostPeerID = self.hostPeerID;
    self.responseKey = [SystemMessage buildRandomString];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hostAcknowledgement:) name:kPartisansNotificationHostAcknowledgement object:nil];
    
    JSKCommandParcel *parcel = [[JSKCommandParcel alloc] initWithType:JSKCommandParcelTypeUpdate to:hostPeerID from:playerEnvoy.peerID object:parcelObject responseKey:self.responseKey];
    [parcelObject release];
    [SystemMessage sendCommandParcel:parcel shouldAwaitResponse:YES];
    [parcel release];
}


- (void)hostAcknowledgement:(NSNotification *)notification
{
    NSString *responseKey = notification.object;
    if (![responseKey isEqualToString:self.responseKey])
    {
        // Oops! Is this really our notification?
        return;
    }
    
    [self.overlayer removeWaitOverlay];
    
    [self goToDecisionScreen:self.menuViewController];
}


- (void)goToDecisionScreen:(JSKMenuViewController *)menuViewController
{
    DecisionMenuItems *items = [[DecisionMenuItems alloc] init];
    self.decisionMenuItems = items;
    [items release];
    
    JSKMenuViewController *vc = [[JSKMenuViewController alloc] init];
    [vc setDelegate:items];
    [menuViewController invokePush:YES viewController:vc];
    [vc release];
}

- (void)gameChanged:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:JSKMenuViewControllerShouldRefresh object:nil];
}


#pragma mark - Host Finder delegate

- (void)hostFinder:(HostFinder *)hostFinder isConnectedToHost:(NSString *)hostPeerID
{
    self.hostPeerID = hostPeerID;
    [self vote:self.thisVote];
}

- (void)hostFinderTimerFired:(HostFinder *)hostFinder
{
    static NSUInteger timeoutCount = 0;
    timeoutCount++;
    if (timeoutCount == 1)
    {
        [self.overlayer updateWaitOverlayText:NSLocalizedString(@"Is the Host available?", @"Is the Host available?  --  message")];
    }
    else if (timeoutCount == 2)
    {
        [self.overlayer updateWaitOverlayText:NSLocalizedString(@"Trying one last time...", @"Trying one last time...  --  message")];
    }
    else
    {
        [hostFinder stop];
        self.hostFinder = nil;
        [self.overlayer removeWaitOverlay];
    }
}


#pragma mark - Menu View Controller delegate



- (void)menuViewControllerDidLoad:(JSKMenuViewController *)menuViewController
{
    if ([self isVotingComplete])
    {
        [self goToDecisionScreen:menuViewController];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameChanged:) name:kPartisansNotificationGameChanged object:nil];
    }
}


- (void)menuViewControllerInvokedRefresh:(JSKMenuViewController *)menuViewController
{
    if ([self isVotingComplete])
    {
        [self goToDecisionScreen:menuViewController];
    }
    else
    {
        [SystemMessage requestGameUpdate];
    }
}


- (void)menuViewController:(JSKMenuViewController *)menuViewController didSelectRowAt:(NSIndexPath *)indexPath
{
    if (indexPath.section == RoundMenuSectionCommand)
    {
        if ([self isReadyForVote])
        {
            // Voting.
            BOOL vote = YES;
            if (indexPath.row == 1)
            {
                vote = NO;
            }
            
            if ([SystemMessage isHost])
            {
                [self voteLocally:vote];
                [self goToDecisionScreen:menuViewController];
                return;
            }
            
            // Stash a reference to the menuViewController, so we can push the results screen when
            // the host acknowledges our vote.
            self.menuViewController = menuViewController;
            [self connectAndVote:vote];
            return;
        }
        else
        {
            if ([self isCoordinator])
            {
                JSKMenuViewController *vc = [[JSKMenuViewController alloc] init];
                [vc setDelegate:self.candidatePickerMenuItems];
                [menuViewController invokePush:YES viewController:vc];
                [vc release];
            }
        }
    }
    
    // Allow the coordinator to undo choices.
    if (indexPath.section == RoundMenuSectionTeam)
    {
        if ([self isCoordinator])
        {
            JSKMenuViewController *vc = [[JSKMenuViewController alloc] init];
            [vc setDelegate:self.candidatePickerMenuItems];
            [menuViewController invokePush:YES viewController:vc];
            [vc release];
        }
    }
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
            if ([self isReadyForVote])
            {
                // Two possible votes: YES and NO.
                returnValue = 2;
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
            if ([self isReadyForVote])
            {
                returnValue = NSLocalizedString(@"Ready for Vote", @"Ready for Vote  --  title");
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
            returnValue = self.currentRound.coordinator.picture.image;
        }
    }
    else if (indexPath.section == RoundMenuSectionTeam)
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
    if (indexPath.section == RoundMenuSectionCommand)
    {
        if (![self isReadyForVote])
        {
            if ([self isCoordinator])
            {
                returnValue = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
    }
    return returnValue;
}

@end
