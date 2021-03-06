//
//  CandidatePickerMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 6/27/13.
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
    UIColor *color = nil;
    PlayerEnvoy *playerEnvoy = [self.players objectAtIndex:indexPath.row];
    if ([self.candidates containsObject:playerEnvoy])
    {
        font = [UIFont systemFontOfSize:17.0];
        color = [UIColor lightGrayColor];
        NSMutableArray *list = [[NSMutableArray alloc] initWithArray:self.candidates];
        [list removeObject:playerEnvoy];
        self.candidates = [NSArray arrayWithArray:list];
    }
    else
    {
        if (self.candidates.count == self.currentMission.teamCount)
        {
            return;
        }
        self.candidates = [self.candidates arrayByAddingObject:playerEnvoy];
        font = [UIFont boldSystemFontOfSize:17.0];
        color = [UIColor blackColor];
    }
    [menuViewController applyLabelFont:font indexPath:indexPath];
    [menuViewController applyLabelColor:color indexPath:indexPath];
    
    
    if (self.candidates.count == self.currentMission.teamCount)
    {
        RoundEnvoy *roundEnvoy = self.currentRound;
        [roundEnvoy clearCandidates];
        for (PlayerEnvoy *candidate in self.candidates)
        {
            [roundEnvoy addCandidate:candidate];
        }
        [menuViewController invokePop:YES];
    }
    
    
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
    returnValue = player.smallImage;
    return returnValue;
}

- (UIFont *)menuViewController:(JSKMenuViewController *)menuViewController labelFontAtIndexPath:(NSIndexPath *)indexPath
{
    PlayerEnvoy *playerEnvoy = [self.players objectAtIndex:indexPath.row];
    if ([self.candidates containsObject:playerEnvoy])
    {
        return [UIFont fontWithName:@"GillSans-Bold" size:18.0];
//        return [UIFont boldSystemFontOfSize:17.0];
    }
    else
    {
        return [UIFont fontWithName:@"GillSans" size:18.0];
//        return [UIFont systemFontOfSize:17.0];
    }
}

- (UIColor *)menuViewController:(JSKMenuViewController *)menuViewController labelColorAtIndexPath:(NSIndexPath *)indexPath
{
    PlayerEnvoy *playerEnvoy = [self.players objectAtIndex:indexPath.row];
    if ([self.candidates containsObject:playerEnvoy])
    {
        return [UIColor blackColor];
    }
    else
    {
        return [UIColor lightGrayColor];
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

- (UITableViewCellAccessoryType)menuViewController:(JSKMenuViewController *)menuViewController cellAccessoryTypeForIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellAccessoryNone;
}

@end
