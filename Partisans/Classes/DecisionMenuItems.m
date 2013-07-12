//
//  DecisionMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 6/28/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "DecisionMenuItems.h"

#import "GameDirector.h"
#import "GameEnvoy.h"
#import "MissionViewController.h"
#import "PlayerEnvoy.h"
#import "ProgressCell.h"
#import "RoundEnvoy.h"
#import "SystemMessage.h"


@interface DecisionMenuItems ()

@property (nonatomic, strong) RoundEnvoy *currentRound;
- (void)gameChanged:(NSNotification *)notification;
- (void)startMission;
- (void)startNewRound;

@end


@implementation DecisionMenuItems

@synthesize currentRound = m_currentRound;


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [m_currentRound release];
    [super dealloc];
}


- (void)gameChanged:(NSNotification *)notification
{
    self.currentRound = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:JSKMenuViewControllerShouldRefresh object:nil];
}


- (RoundEnvoy *)currentRound
{
    if (!m_currentRound)
    {
        self.currentRound = [[SystemMessage gameEnvoy] currentRound];
    }
    return m_currentRound;
}


- (void)startMission
{
    GameDirector *director = [SystemMessage gameDirector];
    [director startMission];
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
    [SystemMessage requestGameUpdate];
}

- (void)menuViewControllerInvokedRefresh:(JSKMenuViewController *)menuViewController
{
    self.currentRound = nil;
    [SystemMessage requestGameUpdate];
}

- (void)menuViewController:(JSKMenuViewController *)menuViewController didSelectRowAt:(NSIndexPath *)indexPath
{
    if (!(indexPath.section == DecisionMenuSectionStatus))
    {
        return;
    }
    
    RoundEnvoy *roundEnvoy = [self currentRound];
    
    if ([roundEnvoy isVotingComplete])
    {
        if ([SystemMessage isHost])
        {
            if ([roundEnvoy voteDidPass])
            {
                [self startMission];
                [menuViewController.navigationController popToRootViewControllerAnimated:YES];
            }
            else
            {
                [self startNewRound];
                [menuViewController.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    }
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
            if ([[self currentRound] isVotingComplete])
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
    RoundEnvoy *roundEnvoy = [self currentRound];

    NSUInteger playerCount = [SystemMessage gameEnvoy].numberOfPlayers;
    NSUInteger votesCast = [roundEnvoy votesCast];
    NSUInteger yeaVotes = [roundEnvoy yeaVotes];
    NSUInteger nayVotes = [roundEnvoy nayVotes];
    
    // The dual progress bar shows the number of required votes to tip the balance.
    // For the nays, this could be different since a tie means the nays win.
    double dualYea = (double)[roundEnvoy yeaMajority] / (double)playerCount;
    double dualNay = (double)[roundEnvoy nayMajority] / (double)playerCount;
    
    NSString *cellPrefix = nil;
    NSString *cellSuffix = nil;
    double progress = 0.0;
    double dualProgress = 0.0;
    
    UIColor *progressColor = playerEnvoy.favoriteColor;
    DecisionMenuVotesRow menuRow = (DecisionMenuVotesRow)indexPath.row;
    switch (menuRow)
    {
        case DecisionMenuVotesRowTotal:
            cellPrefix = [[SystemMessage spellOutInteger:votesCast] capitalizedString];
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
            cellPrefix = [[SystemMessage spellOutInteger:yeaVotes] capitalizedString];
            if (yeaVotes == 1)
            {
                cellSuffix = NSLocalizedString(@"yea vote", @"yea vote  --  label suffix");
            }
            else
            {
                cellSuffix = NSLocalizedString(@"yea votes", @"yea votes  --  label suffix");
            }
            progress = (double)yeaVotes / (double)playerCount;
            dualProgress = dualYea;
            [cell setIsDual:YES];
            progressColor = [UIColor blueColor];
            break;
        case DecisionMenuVotesRowNay:
            cellPrefix = [[SystemMessage spellOutInteger:nayVotes] capitalizedString];
            if (nayVotes == 1)
            {
                cellSuffix = NSLocalizedString(@"nay vote", @"nay vote  --  label suffix");
            }
            else
            {
                cellSuffix = NSLocalizedString(@"nay votes", @"nay votes  --  label suffix");
            }
            progress = (double)nayVotes / (double)playerCount;
            dualProgress = dualNay;
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
    
    RoundEnvoy *roundEnvoy = self.currentRound;
    
    NSString *returnValue = nil;
    if ([roundEnvoy isVotingComplete])
    {
        if ([roundEnvoy voteDidPass])
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
    
    RoundEnvoy *roundEnvoy = self.currentRound;
    
    NSString *returnValue = nil;
    if ([roundEnvoy isVotingComplete])
    {
        if ([SystemMessage isHost])
        {
            if ([roundEnvoy voteDidPass])
            {
                returnValue = NSLocalizedString(@"Tap to start the mission.", @"Tap to start the mission.  --  label");
            }
            else
            {
                returnValue = NSLocalizedString(@"Tap to start a new round.", @"Tap to start a new round.  --  label");
            }
        }
        else
        {
            returnValue = NSLocalizedString(@"Waiting for host...", @"Waiting for host...  --  label");
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
    Class returnValue = nil;
    
//    if (indexPath.section == DecisionMenuSectionStatus)
//    {
//        if ([[self currentRound] isVotingComplete])
//        {
//            returnValue = [MissionViewController class];
//        }
//    }
    
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
//    if (indexPath.section == DecisionMenuSectionStatus)
//    {
//        if ([[self currentRound] isVotingComplete])
//        {
//            return UITableViewCellAccessoryDisclosureIndicator;
//        }
//    }
    return UITableViewCellAccessoryNone;
}

@end
