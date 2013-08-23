//
//  PlayerPicklistItems.m
//  Partisans
//
//  Created by Joshua Kaden on 4/30/13.
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
    [menuViewController invokePop:YES];
}

- (UIImage *)menuViewController:(JSKMenuViewController *)menuViewController imageForIndexPath:(NSIndexPath *)indexPath
{
    PlayerEnvoy *playerEnvoy = [self.players objectAtIndex:indexPath.row];
    return playerEnvoy.smallImage;
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
