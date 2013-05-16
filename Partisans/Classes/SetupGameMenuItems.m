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
                    returnValue = NSLocalizedString(@"Waiting for players...", @"Waiting for players...  --  menu label");
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

