//
//  SetupGameMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 5/15/13.
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

#import "SetupGameMenuItems.h"

#import "DossierDelegate.h"
#import "DossierViewController.h"
#import "GameDirector.h"
#import "GameEnvoy.h"
#import "GamePlayerEnvoy.h"
#import "ImageEnvoy.h"
#import "MissionEnvoy.h"
#import "PlayerEnvoy.h"
#import "RoundMenuItems.h"
#import "ProgressCell.h"
#import "SystemMessage.h"


@interface SetupGameMenuItems ()

@property (nonatomic, strong) NSArray *awaitingApproval;
@property (nonatomic, strong) NSArray *players;
@property (nonatomic, strong) DossierDelegate *dossierDelegate;
@property (nonatomic, strong) UIAlertView *stopHostingAlertView;
@property (nonatomic, strong) UIAlertView *leaveGameAlertView;
@property (nonatomic, assign) JSKMenuViewController *menuViewController;
@property (nonatomic, strong) RoundMenuItems *playerRoundMenuItems;

- (BOOL)isPlayerHost;
- (void)confirmStopHosting;
- (void)confirmLeaveGame;
- (void)handleStopHostingAlertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)handleLeaveGameAlertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)gameChanged:(NSNotification *)notification;
- (void)connectedToHost:(NSNotification *)notification;
- (void)leaveGame;
- (void)startGame;

@end


@implementation SetupGameMenuItems

@synthesize awaitingApproval = m_awaitingApproval;
@synthesize players = m_players;
@synthesize dossierDelegate = m_dossierDelegate;
@synthesize shouldHost = m_shouldHost;
@synthesize stopHostingAlertView = m_stopHostingAlertView;
@synthesize leaveGameAlertView = m_leaveGameAlertView;
@synthesize menuViewController = m_menuViewController;
@synthesize playerRoundMenuItems = m_playerRoundMenuItems;

- (void)dealloc
{
    [m_stopHostingAlertView setDelegate:nil];
    [m_leaveGameAlertView setDelegate:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [m_awaitingApproval release];
    [m_players release];
    [m_dossierDelegate release];
    [m_stopHostingAlertView release];
    [m_leaveGameAlertView release];
    [m_playerRoundMenuItems release];
    
    [super dealloc];
}


- (void)startGame
{
    GameDirector *director = [SystemMessage gameDirector];
    [director startGame];
}

- (void)gameChanged:(NSNotification *)notification
{
    self.players = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:JSKMenuViewControllerShouldRefresh object:nil];
}

- (void)connectedToHost:(NSNotification *)notification
{
//    [SystemMessage requestGameUpdate];
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


#pragma mark - Confirm dialogs


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.stopHostingAlertView)
    {
        [self handleStopHostingAlertView:alertView clickedButtonAtIndex:(NSInteger)buttonIndex];
    }
    if (alertView == self.leaveGameAlertView)
    {
        [self handleLeaveGameAlertView:alertView clickedButtonAtIndex:(NSInteger)buttonIndex];
    }
}

- (void)confirmStopHosting
{
    if (!self.stopHostingAlertView)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Stop Hosting"
                                                            message:@"Would you like to stop hosting, thus ending the game?"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:
                                  @"Yes", nil];
        self.stopHostingAlertView = alertView;
        [alertView release];
    }
    
    [self.stopHostingAlertView show];
}

- (void)confirmLeaveGame
{
    if (self.leaveGameAlertView)
    {
        self.leaveGameAlertView.delegate = nil;
        self.leaveGameAlertView = nil;
    }
    NSString *message = NSLocalizedString(@"Would you like to leave the game?", @"Would you like to leave the game?  --  alert message");
    if ([SystemMessage gameEnvoy].startDate)
    {
        message = NSLocalizedString(@"Would you like to leave the game? This will end the game.", @"Would you like to leave the game? This will end the game.  --  alert message");
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Leave Game"
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:
                              @"Yes", nil];
    self.leaveGameAlertView = alertView;
    [alertView release];
    
    [self.leaveGameAlertView show];
}

- (void)handleStopHostingAlertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            // Cancel
            return;
            break;
            
        case 1:
        {
            // Yes -- stop hosting and end the game.
            // When the players get this message they know that the game is over.
            [SystemMessage broadcastCommandMessage:JSKCommandMessageTypeLeaveGame];
            
            
            GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
            [gameEnvoy deleteGame];
            [[SystemMessage sharedInstance] setGameEnvoy:nil];
            [SystemMessage putPlayerOffline];
            [self.menuViewController invokePop:YES];
            break;
        }
            
        default:
            break;
    }
}

- (void)handleLeaveGameAlertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            // Cancel
            return;
            break;
            
        case 1:
        {
            // Yes -- leave the game.
            // Tell the Host that we're leaving.
            [self performSelectorOnMainThread:@selector(leaveGame) withObject:nil waitUntilDone:YES];
//            [SystemMessage putPlayerOffline];
            break;
        }
        
        default:
            break;
    }
}

- (void)leaveGame
{
    [SystemMessage sendToHost:JSKCommandMessageTypeLeaveGame shouldAwaitResponse:YES];
    
    GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
    [gameEnvoy deleteGame];
    [[SystemMessage sharedInstance] setGameEnvoy:nil];
//    [SystemMessage putPlayerOffline];
    [self.menuViewController invokePop:YES];
}


#pragma mark - Menu VC delegate methods

- (void)menuViewControllerDidLoad:(JSKMenuViewController *)menuViewController
{
    if (![SystemMessage gameEnvoy])
    {
        // Should we start a new game, as host?
        if (self.shouldHost)
        {
            // This is the game creation code.
            GameEnvoy *newEnvoy = [[GameEnvoy alloc] init];
            [newEnvoy addHost:[SystemMessage playerEnvoy]];
            NSUInteger gameCode = arc4random() % (8999 + 1000);
            [newEnvoy setGameCode:gameCode];
            [newEnvoy commitAndSave];
            [[SystemMessage sharedInstance] setGameEnvoy:newEnvoy];
            [newEnvoy release];
        }
    }
    if (![SystemMessage isPlayerOnline])
    {
        [SystemMessage putPlayerOnline];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameChanged:) name:kPartisansNotificationGameChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectedToHost:) name:kPartisansNotificationConnectedToHost object:nil];
}


- (void)menuViewControllerInvokedRefresh:(JSKMenuViewController *)menuViewController
{
    if ([SystemMessage isPlayerOnline])
    {
        if (![self isPlayerHost])
        {
            [SystemMessage sendToHost:JSKCommandMessageTypeGetDigest shouldAwaitResponse:NO];
        }
    }
    else
    {
        [SystemMessage putPlayerOnline];
    }
}


- (void)menuViewController:(JSKMenuViewController *)menuViewController didSelectRowAt:(NSIndexPath *)indexPath
{
    if (indexPath.section == SetupGameMenuSectionGame && indexPath.row == SetupGameMenuRowHost)
    {
        if ([self isPlayerHost])
        {
            self.menuViewController = menuViewController;
            [self confirmStopHosting];
        }
        else
        {
            self.menuViewController = menuViewController;
            [self confirmLeaveGame];
        }
    }
    
    if (indexPath.section == SetupGameMenuSectionGame && indexPath.row == SetupGameMenuRowStatus)
    {
        if ([self isPlayerHost])
        {
            if (self.players.count >= kPartisansMinPlayers)
            {
                if (![SystemMessage gameEnvoy].startDate)
                {
                    [self startGame];
                }
                [menuViewController.navigationController popToRootViewControllerAnimated:YES];
            }
        }
        else
        {
            if ([SystemMessage gameEnvoy].startDate)
            {
                [menuViewController.navigationController popToRootViewControllerAnimated:YES];
            }
        }
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
            NSString *suffix = NSLocalizedString(@"players", @"players  --  label suffix");
            label = [NSString stringWithFormat:@"%@ %@", [[SystemMessage spellOutInteger:self.players.count] capitalizedString], suffix];
        }
        
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
//                    if (![self isPlayerHost])
//                    {
//                        returnValue = UITableViewCellAccessoryDisclosureIndicator;
//                    }
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
            break;
            
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
                        NSString *prefix = NSLocalizedString(@"Your host is", @"Your host is  --  menu label prefix");
                        returnValue = [NSString stringWithFormat:@"%@ %@", prefix, gameEnvoy.host.playerName];
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
                            if (gameEnvoy.startDate)
                            {
                                returnValue = NSLocalizedString(@"Tap to continue.", @"Tap to continue.  --  menu label");
                            }
                            else
                            {
                                returnValue = NSLocalizedString(@"Tap to start the game.", @"Tap to start the game.  --  menu label");
                            }
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
                            if (gameEnvoy.startDate)
                            {
                                returnValue = NSLocalizedString(@"Tap to continue.", @"Tap to continue.  --  menu label");
                            }
                            else
                            {
                                returnValue = NSLocalizedString(@"Waiting for host...", @"Waiting for host...  --  menu label");
                            }
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

- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController subLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SetupGameMenuSectionGame && indexPath.row == SetupGameMenuRowHost)
    {
        if ([self isPlayerHost])
        {
            return NSLocalizedString(@"Tap to stop hosting.", @"Tap to stop hosting.  --  sub label text");
        }
        else
        {
            return NSLocalizedString(@"Tap to leave the game.", @"Tap to leave the game.  --  sub label text");
        }
    }
    
//    if (indexPath.section == SetupGameMenuSectionGame && indexPath.row == SetupGameMenuRowStatus)
//    {
//        GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
//        PlayerEnvoy *playerEnvoy = [SystemMessage playerEnvoy];
//        if (gameEnvoy.startDate)
//        {
//            GamePlayerEnvoy *gamePlayerEnvoy = [gameEnvoy gamePlayerEnvoyFromPlayer:playerEnvoy];
//            if (!gamePlayerEnvoy.hasAlertBeenShown)
//            {
//                return NSLocalizedString(@"Hide your screen!", @"Hide your screen!  --  sub label text");
//            }
//            MissionEnvoy *missionEnvoy = [gameEnvoy currentMission];
//            if (missionEnvoy.hasStarted)
//            {
//                if (([missionEnvoy isPlayerOnTeam:playerEnvoy]) && (![missionEnvoy hasPlayerPerformed:playerEnvoy]))
//                {
//                    return NSLocalizedString(@"Hide your screen!", @"Hide your screen!  --  sub label text");
//                }
//            }
//        }
//    }
    
    return nil;
}


- (NSTextAlignment)menuViewController:(JSKMenuViewController *)menuViewController labelAlignmentAtIndexPath:(NSIndexPath *)indexPath
{
    NSTextAlignment returnValue = NSTextAlignmentLeft;
    if (indexPath.section == SetupGameMenuSectionGame && indexPath.row == SetupGameMenuRowStatus)
    {
        returnValue = NSTextAlignmentCenter;
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
                    returnValue = gameEnvoy.host.smallImage;
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
                returnValue = playerEnvoy.smallImage;
            }
            break;
            
            
            
        case SetupGameMenuSectionPlayers:
            if (self.players.count > 0)
            {
                PlayerEnvoy *playerEnvoy = [self.players objectAtIndex:indexPath.row];
                returnValue = playerEnvoy.smallImage;
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
//                    if (![self isPlayerHost])
//                    {
//                        returnValue = [JSKMenuViewController class];
//                    }
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
//            returnValue = [JSKMenuViewController class];
            break;
            
            
            
        case SetupGameMenuSectionPlayers:
            returnValue = [DossierViewController class];
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
//                    if (![self isPlayerHost])
//                    {
//                        DossierMenuItems *items = [[DossierMenuItems alloc] init];
//                        self.dossierMenuItems = items;
//                        [items release];
//                        return self.dossierMenuItems;
//                    }
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
            break;
            
        case SetupGameMenuSectionPlayers:
        {
            PlayerEnvoy *playerEnvoy = [self.players objectAtIndex:indexPath.row];
            DossierDelegate *delegate = [[DossierDelegate alloc] initWithPlayerEnvoy:playerEnvoy];
            self.dossierDelegate = delegate;
            [delegate release];
            returnValue = self.dossierDelegate;
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

