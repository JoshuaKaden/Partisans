//
//  PlayerPicklistItems.m
//  Partisans
//
//  Created by Joshua Kaden on 4/30/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "PlayerPicklistItems.h"

#import "ImageEnvoy.h"
#import "PlayerEnvoy.h"
#import "PlayerViewController.h"
#import "SystemMessage.h"


@interface PlayerPicklistItems ()

@property (nonatomic, strong) NSArray *players;
@property (nonatomic, strong) JSKMenuViewController *menuViewController;

- (void)addPressed:(id)sender;

@end


@implementation PlayerPicklistItems

@synthesize players = m_players;
@synthesize menuViewController = m_menuViewController;

- (void)dealloc
{
    [m_players release];
    [m_menuViewController release];
    [super dealloc];
}

- (NSArray *)players
{
    if (!m_players)
    {
        NSArray *players = [PlayerEnvoy nativePlayers];
        [self setPlayers:players];
    }
    return m_players;
}

- (NSString *)menuViewControllerTitle:(JSKMenuViewController *)menuViewController
{
    return NSLocalizedString(@"Select Player", @"Select Player  --  title");
}

- (void)menuViewControllerInvokedRefresh:(JSKMenuViewController *)menuViewController
{
    [self setPlayers:nil];
}

- (BOOL)menuViewControllerShouldAutoRefresh:(JSKMenuViewController *)menuViewController
{
    return YES;
}

- (NSInteger)menuViewControllerNumberOfSections:(JSKMenuViewController *)menuViewController
{
    return 1;
}

- (NSInteger)menuViewController:(JSKMenuViewController *)menuViewController numberOfRowsInSection:(NSInteger)section
{
    return self.players.count;
}

- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController labelAtIndexPath:(NSIndexPath *)indexPath
{
    PlayerEnvoy *playerEnvoy = [self.players objectAtIndex:indexPath.row];
    return playerEnvoy.playerName;
}

- (Class)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerClassAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (UITableViewCellAccessoryType)menuViewController:(JSKMenuViewController *)menuViewController cellAccessoryTypeForIndexPath:(NSIndexPath *)indexPath
{
    PlayerEnvoy *playerEnvoy = [self.players objectAtIndex:indexPath.row];
    if (playerEnvoy.isDefault)
    {
        return UITableViewCellAccessoryCheckmark;
    }
    else
    {
        return UITableViewCellAccessoryNone;
    }
}

- (void)menuViewController:(JSKMenuViewController *)menuViewController didSelectRowAt:(NSIndexPath *)indexPath
{
    PlayerEnvoy *playerEnvoy = [self.players objectAtIndex:indexPath.row];
    playerEnvoy.isDefault = YES;
    [playerEnvoy commitAndSave];
    [[SystemMessage sharedInstance] setPlayerEnvoy:playerEnvoy];
    [[SystemMessage sharedInstance] setMyPeerID:playerEnvoy.peerID];
    [menuViewController invokePopAnimated:YES];
}

- (UIImage *)menuViewController:(JSKMenuViewController *)menuViewController imageForIndexPath:(NSIndexPath *)indexPath
{
    PlayerEnvoy *playerEnvoy = [self.players objectAtIndex:indexPath.row];
    return playerEnvoy.picture.image;
}


- (UIBarButtonItem *)menuViewControllerRightButtonItem:(JSKMenuViewController *)menuViewController
{
    UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPressed:)] autorelease];
    self.menuViewController = menuViewController;
    return item;
}

- (void)addPressed:(id)sender
{
    PlayerEnvoy *playerEnvoy = [[PlayerEnvoy alloc] init];
    playerEnvoy.isNative = YES;
    playerEnvoy.isDefault = YES;
    playerEnvoy.favoriteColor = [UIColor grayColor];
    playerEnvoy.isDefaultPicture = YES;
    
    PlayerViewController *vc = [[PlayerViewController alloc] init];
    [vc setPlayerEnvoy:playerEnvoy];
    vc.isAnAdd = YES;
    [playerEnvoy release];
    
    [self.menuViewController.navigationController pushViewController:vc animated:YES];
    
    [vc release];
}

@end
