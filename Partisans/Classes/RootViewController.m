//
//  RootViewController.m
//  Partisans
//
//  Created by Joshua Kaden on 4/19/13.
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

#import "RootViewController.h"

#import "JSKMenuViewController.h"
#import "MainMenuItems.h"
#import "PlayerEnvoy.h"
#import "PlayerViewController.h"
#import "SplashViewController.h"
#import "SystemMessage.h"

@interface RootViewController ()
- (void)commence;
- (void)showFirstViewController;
@end

@implementation RootViewController

#pragma mark - View lifecycle

- (void)loadView
{
    UIImage *image = [UIImage imageNamed:@"splash"];
    self.view = [[UIImageView alloc] initWithImage:image];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Partisans", @"Partisans  --  title");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self commence];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Private

- (void)commence
{
    static BOOL hasCommenced = NO;
    
    if (!hasCommenced) {
        PlayerEnvoy *playerEnvoy = [PlayerEnvoy defaultEnvoy];
        [[SystemMessage sharedInstance] setPlayerEnvoy:playerEnvoy];
    }
    
    [self showFirstViewController];
    
    if (hasCommenced) {
        return;
    }
    
    // Room here for...
    // Mystery code!
    
    hasCommenced = YES;
}

- (void)showFirstViewController
{
    SystemMessage *systemMessage = [SystemMessage sharedInstance];
    if (!systemMessage.hasSplashBeenShown) {
        systemMessage.hasSplashBeenShown = YES;
        SplashViewController *vc = [[SplashViewController alloc] init];
        [self.navigationController pushViewController:vc animated:NO];
        return;
    }
    
    // If there are no default players, then have the user make one.
    PlayerEnvoy *playerEnvoy = [SystemMessage playerEnvoy];
    if (!playerEnvoy) {
        playerEnvoy = [PlayerEnvoy defaultEnvoy];
        [systemMessage setPlayerEnvoy:playerEnvoy];
    }
    
    // If this is a new (unsaved) player, jump right to the edit screen.
    if (!playerEnvoy.managedObjectID) {
        PlayerViewController *vc = [[PlayerViewController alloc] init];
        vc.shouldHideBackButton = YES;
        vc.isAnAdd = YES;
        [self.navigationController pushViewController:vc animated:NO];
        return;
    }
    
    // Launch the main menu.
    JSKMenuViewController *vc = [[JSKMenuViewController alloc] init];
    MainMenuItems *items = [[MainMenuItems alloc] init];
    [vc setMenuItems:items];
    [self.navigationController pushViewController:vc animated:NO];
}

@end
