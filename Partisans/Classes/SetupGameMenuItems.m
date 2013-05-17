//
//  SetupGameMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 5/15/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "SetupGameMenuItems.h"

#import "DossierMenuItems.h"
#import "GameEnvoy.h"
#import "ImageEnvoy.h"
#import "PlayerEnvoy.h"
#import "ProgressCell.h"
#import "SystemMessage.h"


@interface SetupGameMenuItems ()

@property (nonatomic, strong) NSArray *awaitingApproval;
@property (nonatomic, strong) NSArray *players;
@property (nonatomic, strong) DossierMenuItems *dossierMenuItems;

- (BOOL)isPlayerHost;

@end


@implementation SetupGameMenuItems

@synthesize awaitingApproval = m_awaitingApproval;
@synthesize players = m_players;
@synthesize dossierMenuItems = m_dossierMenuItems;

- (void)dealloc
{
    [m_awaitingApproval release];
    [m_players release];
    [m_dossierMenuItems release];
    [super dealloc];
}


- (BOOL)isPlayerHost
{
    PlayerEnvoy *playerEnvoy = [SystemMessage playerEnvoy];
    PlayerEnvoy *hostEnvoy = [[SystemMessage gameEnvoy] host];
    if ([playerEnvoy.intramuralID isEqualToString:hostEnvoy.intramuralID])
    {
        return YES;
    }
    return NO;
}


- (NSArray *)awaitingApproval
{
    if (!m_awaitingApproval)
    {
        [self setAwaitingApproval:[NSArray array]];
    }
    return m_awaitingApproval;
}


- (NSArray *)players
{
    if (!m_players)
    {
        GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
        NSArray *players = [gameEnvoy players];
        [self setPlayers:players];
    }
    return m_players;
}



- (void)menuViewControllerDidLoad:(JSKMenuViewController *)menuViewController
{
    if (![SystemMessage gameEnvoy])
    {
        // In this case we assume that the player is starting a new game, as host.
        GameEnvoy *newEnvoy = [GameEnvoy createGame];
        [[SystemMessage sharedInstance] setGameEnvoy:newEnvoy];
    }
}


- (UITableViewCell *)menuViewController:(JSKMenuViewController *)menuViewController tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SetupGameMenuSectionGame && indexPath.row == SetupGameMenuRowPlayers)
    {
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

        NSString *label = NSLocalizedString(@"More players are needed", @"More players are needed  --  label");
        if (self.players.count == kPartisansMinPlayers - 1)
        {
            label = NSLocalizedString(@"One more player is needed", @"One more player is needed  --  label");
        }
        else if (self.players.count >= kPartisansMinPlayers)
        {
            label = NSLocalizedString(@"Good to go", @"Good to go  --  label");
        }
        
        //NSLocalizedString(@"Players", @"Players  --  label")
        [cell setProgressLabelText:label];
        
        [cell setIsDual:YES];
        
        PlayerEnvoy *playerEnvoy = [SystemMessage playerEnvoy];
        [cell setProgressTintColor:playerEnvoy.favoriteColor];
        [cell setDualProgressTintColor:[UIColor lightGrayColor]];
        
        double progress = (double)self.players.count / (double)kPartisansMaxPlayers;
        [cell setProgress:progress animated:YES];
        
        double dualProgress = (double)kPartisansMinPlayers / (double)kPartisansMaxPlayers;
        [cell setDualProgress:dualProgress animated:YES];
        
        return (UITableViewCell*)cell;
    }
    return nil;
}

- (float)menuViewController:(JSKMenuViewController *)menuViewController heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SetupGameMenuSectionGame && indexPath.row == SetupGameMenuRowPlayers)
    {
        return 70.0f;
    }
    else
    {
        return 44.0f;
    }
}


- (UIColor *)menuViewController:(JSKMenuViewController *)menuViewController labelColorAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *returnValue = [UIColor blackColor];
    switch ((SetupGameMenuSection)indexPath.section) {
            
            
        case SetupGameMenuSectionGame:
        {
            switch ((SetupGameMenuRow)indexPath.row)
            {
                case SetupGameMenuRowHost:
                case SetupGameMenuRowPlayers:
                    break;
                    
                case SetupGameMenuRowStatus:
                    returnValue = [UIColor darkGrayColor];
                    break;
                    
                case SetupGameMenuRow_MaxValue:
                    break;
            }
            break;
        }
            
            
        case SetupGameMenuSectionAwaitingApproval:
        case SetupGameMenuSectionPlayers:
            break;
            
            
            
        case SetupGameMenuSection_MaxValue:
            break;
    }
    
    return returnValue;
}



- (UITableViewCellAccessoryType)menuViewController:(JSKMenuViewController *)menuViewController cellAccessoryTypeForIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellAccessoryType returnValue = UITableViewCellAccessoryNone;
    switch ((SetupGameMenuSection)indexPath.section) {
            
            
        case SetupGameMenuSectionGame:
        {
            switch ((SetupGameMenuRow)indexPath.row)
            {
                case SetupGameMenuRowHost:
                    returnValue = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                case SetupGameMenuRowPlayers:
                case SetupGameMenuRowStatus:
                    break;
                    
                case SetupGameMenuRow_MaxValue:
                    break;
            }
            break;
        }

            
        case SetupGameMenuSectionAwaitingApproval:
        case SetupGameMenuSectionPlayers:
            returnValue = UITableViewCellAccessoryDisclosureIndicator;
            break;
            
            
            
        case SetupGameMenuSection_MaxValue:
            break;
    }
    
    return returnValue;
}


- (BOOL)menuViewControllerShouldAutoRefresh:(JSKMenuViewController *)menuViewController
{
    return YES;
}


- (NSInteger)menuViewControllerNumberOfSections:(JSKMenuViewController *)menuViewController
{
    return 3;
}


- (NSInteger)menuViewController:(JSKMenuViewController *)menuViewController numberOfRowsInSection:(NSInteger)section
{
    NSInteger returnValue;
    switch ((SetupGameMenuSection)section) {
        case SetupGameMenuSectionGame:
            returnValue = SetupGameMenuRow_MaxValue;
            break;
        case SetupGameMenuSectionAwaitingApproval:
            returnValue = self.awaitingApproval.count;
            break;
        case SetupGameMenuSectionPlayers:
            returnValue = self.players.count;
            break;
        case SetupGameMenuSection_MaxValue:
            returnValue = 0;
            break;
    }
    return returnValue;
}



- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController titleForHeaderInSection:(NSInteger)section
{
    NSString *returnValue = nil;
    switch ((SetupGameMenuSection)section) {
        case SetupGameMenuSectionGame:
            returnValue = NSLocalizedString(@"Game", @"Game  --  section title");
            break;
        case SetupGameMenuSectionAwaitingApproval:
            if (self.awaitingApproval.count > 0)
            {
                returnValue = NSLocalizedString(@"Awaiting Approval", @"Awaiting Approval  --  section title");
            }
            break;
        case SetupGameMenuSectionPlayers:
            if (self.players.count > 0)
            {
                returnValue = NSLocalizedString(@"Players", @"Players  --  section title");
            }
            break;
        case SetupGameMenuSection_MaxValue:
            returnValue = 0;
            break;
    }
    return returnValue;
}


- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController labelAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *returnValue = nil;
    switch ((SetupGameMenuSection)indexPath.section) {
            

        case SetupGameMenuSectionGame:
        {
            GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
            switch ((SetupGameMenuRow)indexPath.row)
            {
                case SetupGameMenuRowHost:
                    if ([self isPlayerHost])
                    {
                        returnValue = NSLocalizedString(@"You are the host", @"You are the host  --  menu label");
                    }
                    else
                    {
                        returnValue = gameEnvoy.host.playerName;
                    }
                    break;
                    
                case SetupGameMenuRowPlayers:
                    break;
                    
                case SetupGameMenuRowStatus:
                    if ([self isPlayerHost])
                    {
                        if (self.players.count < kPartisansMinPlayers)
                        {
                            returnValue = NSLocalizedString(@"Waiting for players...", @"Waiting for players...  --  menu label");
                        }
                        else
                        {
                            returnValue = NSLocalizedString(@"Ready to start game.", @"Ready to start game.  --  menu label");
                        }
                    }
                    else
                    {
                        if (self.players.count < kPartisansMinPlayers)
                        {
                            returnValue = NSLocalizedString(@"Waiting for more players...", @"Waiting for more players...  --  menu label");
                        }
                        else
                        {
                            returnValue = NSLocalizedString(@"Waiting for host...", @"Waiting for host...  --  menu label");
                        }
                    }
                    break;
                    
                case SetupGameMenuRow_MaxValue:
                    break;
            }
            break;
        }
        
            
        case SetupGameMenuSectionAwaitingApproval:
            if (self.awaitingApproval.count > 0)
            {
                PlayerEnvoy *playerEnvoy = [self.awaitingApproval objectAtIndex:indexPath.row];
                returnValue = playerEnvoy.playerName;
            }
            break;
            
            
            
        case SetupGameMenuSectionPlayers:
            if (self.players.count > 0)
            {
                PlayerEnvoy *playerEnvoy = [self.players objectAtIndex:indexPath.row];
                returnValue = playerEnvoy.playerName;
            }
            break;
            
            
            
        case SetupGameMenuSection_MaxValue:
            break;
    }
    
    return returnValue;
}


- (UIImage *)menuViewController:(JSKMenuViewController *)menuViewController imageForIndexPath:(NSIndexPath *)indexPath
{
    UIImage *returnValue = nil;
    switch ((SetupGameMenuSection)indexPath.section) {
            
            
        case SetupGameMenuSectionGame:
        {
            GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
            switch ((SetupGameMenuRow)indexPath.row)
            {
                case SetupGameMenuRowHost:
                    returnValue = gameEnvoy.host.picture.image;
                    break;
                    
                case SetupGameMenuRowPlayers:
                    break;
                    
                case SetupGameMenuRowStatus:
                    break;
                    
                case SetupGameMenuRow_MaxValue:
                    break;
            }
            break;
        }
        
        
        case SetupGameMenuSectionAwaitingApproval:
            if (self.awaitingApproval.count > 0)
            {
                PlayerEnvoy *playerEnvoy = [self.awaitingApproval objectAtIndex:indexPath.row];
                returnValue = playerEnvoy.picture.image;
            }
            break;
            
            
            
        case SetupGameMenuSectionPlayers:
            if (self.players.count > 0)
            {
                PlayerEnvoy *playerEnvoy = [self.players objectAtIndex:indexPath.row];
                returnValue = playerEnvoy.picture.image;
            }
            break;
            
            
            
        case SetupGameMenuSection_MaxValue:
            break;
    }
    
    return returnValue;
}




- (Class)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerClassAtIndexPath:(NSIndexPath *)indexPath
{
    Class returnValue = nil;
    switch ((SetupGameMenuSection)indexPath.section) {
            
            
        case SetupGameMenuSectionGame:
        {
            switch ((SetupGameMenuRow)indexPath.row)
            {
                case SetupGameMenuRowHost:
                    returnValue = [JSKMenuViewController class];
                    break;
                    
                case SetupGameMenuRowPlayers:
                case SetupGameMenuRowStatus:
                    break;
                    
                case SetupGameMenuRow_MaxValue:
                    break;
            }
            break;
        }
            
            
        case SetupGameMenuSectionAwaitingApproval:
            returnValue = [JSKMenuViewController class];
            break;
            
            
            
        case SetupGameMenuSectionPlayers:
            returnValue = [JSKMenuViewController class];
            break;
            
            
            
        case SetupGameMenuSection_MaxValue:
            break;
    }
    
    return returnValue;
}


- (id)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerDelegateAtIndexPath:(NSIndexPath *)indexPath
{
    id returnValue = nil;
    switch ((SetupGameMenuSection)indexPath.section) {
            
            
        case SetupGameMenuSectionGame:
        {
            switch ((SetupGameMenuRow)indexPath.row)
            {
                case SetupGameMenuRowHost:
                {
                    DossierMenuItems *items = [[DossierMenuItems alloc] init];
                    self.dossierMenuItems = items;
                    [items release];
                    return self.dossierMenuItems;
                    break;
                }
                    
                case SetupGameMenuRowPlayers:
                case SetupGameMenuRowStatus:
                    break;
                    
                case SetupGameMenuRow_MaxValue:
                    break;
            }
            break;
        }
            
            
        case SetupGameMenuSectionAwaitingApproval:
        case SetupGameMenuSectionPlayers:
        {
            DossierMenuItems *items = [[DossierMenuItems alloc] init];
            self.dossierMenuItems = items;
            [items release];
            return self.dossierMenuItems;
            break;
        }
            
            
            
        case SetupGameMenuSection_MaxValue:
            break;
    }
    
    return returnValue;
}



- (NSString *)menuViewControllerTitle:(JSKMenuViewController *)menuViewController
{
    return NSLocalizedString(@"Setup", @"Setup  --  title");
}

@end

