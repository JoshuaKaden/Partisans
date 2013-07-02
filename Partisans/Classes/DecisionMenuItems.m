//
//  DecisionMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 6/28/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "DecisionMenuItems.h"
#import "GameEnvoy.h"
#import "PlayerEnvoy.h"
#import "ProgressCell.h"
#import "RoundEnvoy.h"
#import "SystemMessage.h"


@interface DecisionMenuItems ()

- (BOOL)isVotingComplete;
- (BOOL)didPass;
- (NSUInteger)votesCast;
- (NSUInteger)yeaVotes;
- (NSUInteger)nayVotes;

@end


@implementation DecisionMenuItems

- (void)dealloc
{
    [super dealloc];
}


- (BOOL)isVotingComplete
{
    GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
    RoundEnvoy *roundEnvoy = [gameEnvoy currentRound];
    if (roundEnvoy.votes.count == gameEnvoy.numberOfPlayers)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (BOOL)didPass
{
    if (![self isVotingComplete])
    {
        return NO;
    }
    NSUInteger playerCount = [SystemMessage gameEnvoy].numberOfPlayers;
    double majority = ((double)playerCount / (double)2.0) + (double)1.0;
    if ([self yeaVotes] >= majority)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSUInteger)votesCast
{
    GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
    RoundEnvoy *roundEnvoy = [gameEnvoy currentRound];
    NSArray *cast = [roundEnvoy.votes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isCast == YES"]];
    return cast.count;
}

- (NSUInteger)yeaVotes
{
    GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
    RoundEnvoy *roundEnvoy = [gameEnvoy currentRound];
    NSArray *yeas = [roundEnvoy.votes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isYea == YES"]];
    return yeas.count;
}

- (NSUInteger)nayVotes
{
    GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
    RoundEnvoy *roundEnvoy = [gameEnvoy currentRound];
    NSArray *nays = [roundEnvoy.votes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isYea == NO"]];
    return nays.count;
}



#pragma mark - Menu View Controller delegate

- (void)menuViewController:(JSKMenuViewController *)menuViewController didSelectRowAt:(NSIndexPath *)indexPath
{
    
}

- (NSString *)menuViewControllerTitle:(JSKMenuViewController *)menuViewController
{
    NSString *title = NSLocalizedString(@"Team Decision", @"Team Decision  --  title");
    return title;
}

- (NSInteger)menuViewControllerNumberOfSections:(JSKMenuViewController *)menuViewController
{
    return DecisionMenuSection_MaxValue;
}

- (NSInteger)menuViewController:(JSKMenuViewController *)menuViewController numberOfRowsInSection:(NSInteger)section
{
    NSInteger returnValue = 0;
    
    DecisionMenuSection menuSection = (DecisionMenuSection)section;
    switch (menuSection)
    {
        case DecisionMenuSectionStatus:
            returnValue = 1;
            break;
        case DecisionMenuSectionVotes:
            if ([self isVotingComplete])
            {
                returnValue = 3;
            }
            else
            {
                returnValue = 1;
            }
            break;
        case DecisionMenuSection_MaxValue:
            break;
    }
    return returnValue;
}

- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController titleForHeaderInSection:(NSInteger)section
{
    NSString *returnValue = nil;
    DecisionMenuSection menuSection = (DecisionMenuSection)section;
    switch (menuSection)
    {
        case DecisionMenuSectionStatus:
            returnValue = NSLocalizedString(@"Status", @"Status  --  label");
            break;
        case DecisionMenuSectionVotes:
            returnValue = NSLocalizedString(@"Votes", @"Votes  --  label");
            break;
        case DecisionMenuSection_MaxValue:
            break;
    }
    return returnValue;
}


- (UITableViewCell *)menuViewController:(JSKMenuViewController *)menuViewController tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != DecisionMenuSectionVotes)
    {
        return nil;
    }
    
    static NSString * customCellIdentifier = @"ProgressCellIdentifier";
    
    ProgressCell *cell = (ProgressCell *)[tableView dequeueReusableCellWithIdentifier:customCellIdentifier];
    
    if (!cell) // tableview not associated (registered) with nib file.
    {
        UINib *customCellNib = [UINib nibWithNibName:@"ProgressCell" bundle:nil];
        // Register this nib file with cell identifier.
        [tableView registerNib: customCellNib forCellReuseIdentifier:customCellIdentifier];
    }
    
    // call dequeueReusableCellWithIdentifier function and now you will get cell object
    cell = (ProgressCell *)[tableView dequeueReusableCellWithIdentifier:customCellIdentifier];
    
    
    PlayerEnvoy *playerEnvoy = [SystemMessage playerEnvoy];

    NSUInteger playerCount = [SystemMessage gameEnvoy].numberOfPlayers;
    NSUInteger votesCast = [self votesCast];
    NSUInteger yeaVotes = [self yeaVotes];
    NSUInteger nayVotes = [self nayVotes];
    
    
    NSString *cellPrefix = nil;
    NSString *cellSuffix = nil;
    double progress = 0.0;
    double majority = ((double)playerCount / (double)2.0) + (double)1.0;
    double dualProgress = majority;
    UIColor *progressColor = playerEnvoy.favoriteColor;
    DecisionMenuVotesRow menuRow = (DecisionMenuVotesRow)indexPath.row;
    switch (menuRow)
    {
        case DecisionMenuVotesRowTotal:
            cellPrefix = [[SystemMessage spellOutInteger:[self votesCast]] capitalizedString];
            if (votesCast == 1)
            {
                cellSuffix = NSLocalizedString(@"vote cast", @"vote cast  --  label suffix");
            }
            else
            {
                cellSuffix = NSLocalizedString(@"votes cast", @"votes cast  --  label suffix");
            }
            progress = (double)votesCast / (double)playerCount;
            [cell setIsDual:NO];
            break;
        case DecisionMenuVotesRowYea:
            cellPrefix = [[SystemMessage spellOutInteger:[self yeaVotes]] capitalizedString];
            if (yeaVotes == 1)
            {
                cellSuffix = NSLocalizedString(@"yea vote", @"yea vote  --  label suffix");
            }
            else
            {
                cellSuffix = NSLocalizedString(@"yea votes", @"yea votes  --  label suffix");
            }
            progress = (double)yeaVotes / (double)playerCount;
            [cell setIsDual:YES];
            progressColor = [UIColor blueColor];
            break;
        case DecisionMenuVotesRowNay:
            cellPrefix = [[SystemMessage spellOutInteger:[self nayVotes]] capitalizedString];
            if (nayVotes == 1)
            {
                cellSuffix = NSLocalizedString(@"nay vote", @"nay vote  --  label suffix");
            }
            else
            {
                cellSuffix = NSLocalizedString(@"nay votes", @"nay votes  --  label suffix");
            }
            progress = (double)nayVotes / (double)playerCount;
            [cell setIsDual:YES];
            progressColor = [UIColor redColor];
            break;
        case DecisionMenuVotesRow_MaxValue:
            break;
    }
    NSString *cellLabel = [NSString stringWithFormat:@"%@ %@", cellPrefix, cellSuffix];
    [cell setProgressLabelText:cellLabel];
    
    [cell setProgressTintColor:progressColor];
    [cell setProgress:progress animated:YES];
    
    if (cell.isDual)
    {
        [cell setDualProgressTintColor:[UIColor lightGrayColor]];
        [cell setDualProgress:dualProgress animated:YES];
    }
    
    
    
    return (UITableViewCell*)cell;
}


- (float)menuViewController:(JSKMenuViewController *)menuViewController heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == DecisionMenuSectionVotes)
    {
        return 70.0f;
    }
    else
    {
        return 44.0f;
    }
}



- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController labelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != DecisionMenuSectionStatus)
    {
        return nil;
    }
    
    NSString *returnValue = nil;
    if ([self isVotingComplete])
    {
        if ([self didPass])
        {
            returnValue = NSLocalizedString(@"The yeas have it!", @"The yeas have it!  --  label");
        }
        else
        {
            returnValue = NSLocalizedString(@"The nays have it.", @"The nays have it.  --  label");
        }
    }
    else
    {
        returnValue = NSLocalizedString(@"Voting in progress...", @"Voting in progress...  --  label");
    }
    return returnValue;
}

- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController subLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != DecisionMenuSectionStatus)
    {
        return nil;
    }
    
    NSString *returnValue = nil;
    if ([self isVotingComplete])
    {
        if ([self didPass])
        {
            returnValue = NSLocalizedString(@"Tap to start the mission.", @"Tap to start the mission.  --  label");
        }
        else
        {
            returnValue = NSLocalizedString(@"Tap to start a new round.", @"Tap to start a new round.  --  label");
        }
    }
    return returnValue;
}

- (UIImage *)menuViewController:(JSKMenuViewController *)menuViewController imageForIndexPath:(NSIndexPath *)indexPath
{
    return nil;
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
