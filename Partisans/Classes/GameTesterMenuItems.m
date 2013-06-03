//
//  GameSetupTesterMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 6/2/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "GameTesterMenuItems.h"

#import "GameEnvoy.h"
#import "ImageEnvoy.h"
#import "PlayerEnvoy.h"
#import "SystemMessage.h"


@interface GameTesterMenuItems ()

@property (nonatomic, strong) NSArray *players;
- (void)addPlayers;
- (void)removePlayers;

@end


@implementation GameTesterMenuItems

@synthesize players = m_players;

- (void)dealloc
{
    [m_players release];
    [super dealloc];
}


#pragma mark - Overridden accessors

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


#pragma mark - Private

- (void)addPlayers
{
    GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
    NSArray *players = [PlayerEnvoy nativePlayers];
    for (PlayerEnvoy *playerEnvoy in players)
    {
        [gameEnvoy addPlayer:playerEnvoy];
    }
    [gameEnvoy commitAndSave];
    self.players = nil;
}

- (void)removePlayers
{
    GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
    NSArray *players = [PlayerEnvoy nativePlayers];
    for (PlayerEnvoy *playerEnvoy in players)
    {
        [gameEnvoy removePlayer:playerEnvoy];
    }
    [gameEnvoy commitAndSave];
    self.players = nil;
}


#pragma mark - MenuViewController delegate

- (NSString *)menuViewControllerTitle:(JSKMenuViewController *)menuViewController
{
    return NSLocalizedString(@"Game Tester", @"Game Tester  --  title");
}

- (NSInteger)menuViewControllerNumberOfSections:(JSKMenuViewController *)menuViewController
{
    return GameTesterMenuSection_MaxValue;
}

- (NSInteger)menuViewController:(JSKMenuViewController *)menuViewController numberOfRowsInSection:(NSInteger)section
{
    NSInteger returnValue = 0;
    GameTesterMenuSection menuSection = section;
    switch (menuSection)
    {
        case GameTesterMenuSectionAction:
            returnValue = GameTesterMenuRow_MaxValue;
            break;
        case GameTesterMenuSectionPlayers:
            returnValue = self.players.count;
            break;
        case GameTesterMenuSection_MaxValue:
            break;
    }
    return returnValue;
}

- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController titleForHeaderInSection:(NSInteger)section
{
    NSString *returnValue = nil;
    GameTesterMenuSection menuSection = section;
    switch (menuSection) {
        case GameTesterMenuSectionAction:
            returnValue = @"Action";
            break;
        case GameTesterMenuSectionPlayers:
            returnValue = @"Players";
            break;
        case GameTesterMenuSection_MaxValue:
            break;
    }
    return returnValue;
}

- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController labelAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *returnValue = nil;
    GameTesterMenuSection menuSection = indexPath.section;
    switch (menuSection) {
        case GameTesterMenuSectionAction:
        {
            GameTesterMenuRow menuRow = indexPath.row;
            switch (menuRow) {
                case GameTesterMenuRowAddPlayers:
                    returnValue = @"Add Players";
                    break;
                case GameTesterMenuRowRemovePlayers:
                    returnValue = @"Remove Players";
                    break;
                case GameTesterMenuRow_MaxValue:
                    break;
            }
            break;
        }
        case GameTesterMenuSectionPlayers:
        {
            if (self.players.count > 0)
            {
                PlayerEnvoy *playerEnvoy = [self.players objectAtIndex:indexPath.row];
                returnValue = playerEnvoy.playerName;
            }
            break;
        }
        case GameTesterMenuSection_MaxValue:
            break;
    }
    return returnValue;
}

- (UIImage *)menuViewController:(JSKMenuViewController *)menuViewController imageForIndexPath:(NSIndexPath *)indexPath
{
    UIImage *returnValue = nil;
    GameTesterMenuSection menuSection = indexPath.section;
    switch (menuSection) {
        case GameTesterMenuSectionAction:
            break;
        case GameTesterMenuSectionPlayers:
        {
            if (self.players.count > 0)
            {
                PlayerEnvoy *playerEnvoy = [self.players objectAtIndex:indexPath.row];
                returnValue = playerEnvoy.picture.image;
            }
            break;
        }
        case GameTesterMenuSection_MaxValue:
            break;
    }
    return returnValue;
}

- (Class)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerClassAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)menuViewControllerInvokedRefresh:(JSKMenuViewController *)menuViewController
{
    self.players = nil;
}

- (void)menuViewController:(JSKMenuViewController *)menuViewController didSelectRowAt:(NSIndexPath *)indexPath
{
    GameTesterMenuSection menuSection = indexPath.section;
    if (!(menuSection == GameTesterMenuSectionAction))
    {
        return;
    }
    GameTesterMenuRow menuRow = indexPath.row;
    switch (menuRow) {
        case GameTesterMenuRowAddPlayers:
            [self addPlayers];
            break;
        case GameTesterMenuRowRemovePlayers:
            [self removePlayers];
            break;
        case GameTesterMenuRow_MaxValue:
            return;
            break;
    }
    [menuViewController refreshData:YES];
}

- (UITableViewCellAccessoryType)menuViewController:(JSKMenuViewController *)menuViewController cellAccessoryTypeForIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellAccessoryNone;
}

@end
