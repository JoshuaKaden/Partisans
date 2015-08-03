//
//  DossiersMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 8/28/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "DossiersMenuItems.h"

#import "DossierDelegate.h"
#import "DossierViewController.h"
#import "GameEnvoy.h"
#import "PlayerEnvoy.h"
#import "SystemMessage.h"


@interface DossiersMenuItems ()

@property (nonatomic, strong) NSArray *players;
@property (nonatomic, strong) DossierDelegate *dossierDelegate;

@end


@implementation DossiersMenuItems

@synthesize players = m_players;
@synthesize dossierDelegate = m_dossierDelegate;





#pragma mark - MenuVC delegate

- (void)menuViewControllerDidLoad:(JSKMenuViewController *)menuViewController
{
    GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
    if (!gameEnvoy)
    {
        self.players = [NSArray array];
        return;
    }
    self.players = [gameEnvoy players];
}

- (NSString *)menuViewControllerTitle:(JSKMenuViewController *)menuViewController
{
    return NSLocalizedString(@"Dossiers", @"Dossiers  --  title");
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

- (UIImage *)menuViewController:(JSKMenuViewController *)menuViewController imageForIndexPath:(NSIndexPath *)indexPath
{
    PlayerEnvoy *playerEnvoy = [self.players objectAtIndex:indexPath.row];
    return playerEnvoy.smallImage;
}

- (Class)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerClassAtIndexPath:(NSIndexPath *)indexPath
{
    return [DossierViewController class];
}

- (id)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerDelegateAtIndexPath:(NSIndexPath *)indexPath
{
    PlayerEnvoy *playerEnvoy = [self.players objectAtIndex:indexPath.row];
    DossierDelegate *delegate = [[DossierDelegate alloc] initWithPlayerEnvoy:playerEnvoy];
    self.dossierDelegate = delegate;
    return self.dossierDelegate;
}

- (BOOL)menuViewControllerHidesRefreshButton:(JSKMenuViewController *)menuViewController
{
    return YES;
}

@end
