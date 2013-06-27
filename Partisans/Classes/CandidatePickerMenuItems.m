//
//  CandidatePickerMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 6/27/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "CandidatePickerMenuItems.h"

//#import "DossierMenuItems.h"
#import "GameEnvoy.h"
#import "ImageEnvoy.h"
#import "MissionEnvoy.h"
#import "PlayerEnvoy.h"
#import "RoundEnvoy.h"
#import "SystemMessage.h"


@interface CandidatePickerMenuItems ()

@property (nonatomic, strong) GameEnvoy *gameEnvoy;
@property (nonatomic, strong) RoundEnvoy *currentRound;
@property (nonatomic, strong) MissionEnvoy *currentMission;
@property (nonatomic, strong) NSArray *players;
@property (nonatomic, strong) NSArray *candidates;
//@property (nonatomic, strong) DossierMenuItems *dossierMenuItems;

@end


@implementation CandidatePickerMenuItems

@synthesize gameEnvoy = m_gameEnvoy;
@synthesize currentRound = m_currentRound;
@synthesize currentMission = m_currentMission;
@synthesize players = m_players;
@synthesize candidates = m_candidates;
//@synthesize dossierMenuItems = m_dossierMenuItems;


- (void)dealloc
{
    [m_gameEnvoy release];
    [m_currentRound release];
    [m_currentMission release];
    [m_players release];
    [m_candidates release];
//    [m_dossierMenuItems release];
    [super dealloc];
}


//- (DossierMenuItems *)dossierMenuItems
//{
//    if (!m_dossierMenuItems)
//    {
//        DossierMenuItems *items = [[DossierMenuItems alloc] init];
//        self.dossierMenuItems = items;
//        [items release];
//    }
//    return m_dossierMenuItems;
//}

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

- (NSArray *)players
{
    if (!m_players)
    {
        self.players = [self.gameEnvoy players];
    }
    return m_players;
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


#pragma mark - Menu View Controller delegate

- (void)menuViewController:(JSKMenuViewController *)menuViewController didSelectRowAt:(NSIndexPath *)indexPath
{
    UIFont *font = nil;
    PlayerEnvoy *playerEnvoy = [self.players objectAtIndex:indexPath.row];
    if ([self.candidates containsObject:playerEnvoy])
    {
        font = [UIFont systemFontOfSize:17.0];
        NSMutableArray *list = [[NSMutableArray alloc] initWithArray:self.candidates];
        [list removeObject:playerEnvoy];
        self.candidates = [NSArray arrayWithArray:list];
        [list release];
    }
    else
    {
        self.candidates = [self.candidates arrayByAddingObject:playerEnvoy];
        font = [UIFont boldSystemFontOfSize:17.0];
    }
    [menuViewController applyLabelFont:font indexPath:indexPath];
    
//    PlayerEnvoy *selected = [self.players objectAtIndex:indexPath.row];
//    [self.dossierMenuItems setPlayerEnvoy:selected];
}

- (NSString *)menuViewControllerTitle:(JSKMenuViewController *)menuViewController
{
    NSString *title = NSLocalizedString(@"Team Selection", @"Team Selection  --  title");
    return title;
}

- (NSInteger)menuViewControllerNumberOfSections:(JSKMenuViewController *)menuViewController
{
    return 1;
}

- (NSInteger)menuViewController:(JSKMenuViewController *)menuViewController numberOfRowsInSection:(NSInteger)section
{
    return self.players.count;
}

- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController titleForHeaderInSection:(NSInteger)section
{
    NSString *prefix = NSLocalizedString(@"Requires", @"Requires  --  title prefix");
    NSString *spelledNumber = [SystemMessage spellOutNumber:[NSNumber numberWithUnsignedInteger:self.currentMission.teamCount]];
    NSString *suffix = NSLocalizedString(@"members", @"members  --  title suffix");
    return [NSString stringWithFormat:@"%@ %@ %@", prefix, spelledNumber, suffix];
}

- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController labelAtIndexPath:(NSIndexPath *)indexPath
{
    PlayerEnvoy *player = [self.players objectAtIndex:indexPath.row];
    return player.playerName;
}

- (UIImage *)menuViewController:(JSKMenuViewController *)menuViewController imageForIndexPath:(NSIndexPath *)indexPath
{
    UIImage *returnValue = nil;
    PlayerEnvoy *player = [self.players objectAtIndex:indexPath.row];
    returnValue = player.picture.image;
    return returnValue;
}

- (UIFont *)menuViewController:(JSKMenuViewController *)menuViewController labelFontAtIndexPath:(NSIndexPath *)indexPath
{
    PlayerEnvoy *playerEnvoy = [self.players objectAtIndex:indexPath.row];
    if ([self.candidates containsObject:playerEnvoy])
    {
        return [UIFont boldSystemFontOfSize:17.0];
    }
    else
    {
        return [UIFont systemFontOfSize:17.0];
    }
}

- (Class)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerClassAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
//    return [JSKMenuViewController class];
}

//- (id)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerDelegateAtIndexPath:(NSIndexPath *)indexPath
//{
//    return self.dossierMenuItems;
//}

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

@end
