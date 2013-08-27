//
//  ToolsMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 5/23/13.
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

#import "ToolsMenuItems.h"

#import "AboutMenuItems.h"
//#import "GameCodeViewController.h"
#import "SplashViewController.h"

//#import "TestCodeViewController.h"
//#import "GameTesterMenuItems.h"
//#import "OverlayTesterViewController.h"


@interface ToolsMenuItems()

//@property (nonatomic, strong) GameTesterMenuItems *gameTesterMenuItems;
@property (nonatomic, strong) AboutMenuItems *aboutMenuItems;

@end


@implementation ToolsMenuItems

//@synthesize gameTesterMenuItems = m_gameTesterMenuItems;
@synthesize aboutMenuItems = m_aboutMenuItems;

- (void)dealloc
{
    [m_aboutMenuItems release];
//    [m_gameTesterMenuItems release];
    [super dealloc];
}


- (BOOL)menuViewControllerHidesRefreshButton:(JSKMenuViewController *)menuViewController
{
    return YES;
}

- (NSInteger)menuViewControllerNumberOfSections:(JSKMenuViewController *)menuViewController
{
    return 1;
}


- (NSInteger)menuViewController:(JSKMenuViewController *)menuViewController numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return ToolsMenuRow_MaxValue;
    }
    else
    {
        return 0;
    }
}


- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController labelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section > 0)
    {
        return nil;
    }
    
    NSString *label = nil;
    
    switch (indexPath.row)
    {
        case ToolsMenuRowAbout:
            label = NSLocalizedString(@"About", @"About  --  menu label");
            break;
            
//        case ToolsMenuRowTestEditCode:
//            label = NSLocalizedString(@"Test Edit Code View", @"Test Edit Code View  --  label");
//            break;
            
        case ToolsMenuRowSplash:
            label = NSLocalizedString(@"Splash Screen", @"Splash Screen  --  label");
            break;
            
//        case ToolsMenuRowClearRemoteData:
//            label = NSLocalizedString(@"Clear Remote Data", @"Clear Remote Data  --  menu label");
//            break;
//
//        case ToolsMenuRowGameTester:
//            label = NSLocalizedString(@"Game Setup Tester", @"Game Setup Tester  --  menu label");
//            break;
//            
//        case ToolsMenuRowServerTester:
//            label = NSLocalizedString(@"Server Tester", @"Server Tester  --  menu label");
//            break;
//            
//        case ToolsMenuRowOverlayTester:
//            label = NSLocalizedString(@"Overlay Tester", @"Overlay Tester  --  menu label");
//            break;
            
        case ToolsMenuRow_MaxValue:
            break;
    }
    
    return label;
}



- (Class)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerClassAtIndexPath:(NSIndexPath *)indexPath
{
    Class targetClass = nil;
    
    switch (indexPath.row)
    {
        case ToolsMenuRowAbout:
            targetClass = [JSKMenuViewController class];
            break;
            
//        case ToolsMenuRowTestEditCode:
//            targetClass = [GameCodeViewController class];
//            break;
            
        case ToolsMenuRowSplash:
            targetClass = [SplashViewController class];
            break;
            
//        case ToolsMenuRowClearRemoteData:
//            break;
//            
//        case ToolsMenuRowGameTester:
//            targetClass = [JSKMenuViewController class];
//            break;
//
//        case ToolsMenuRowServerTester:
//            targetClass = [JSKMenuViewController class];
//            break;
//            
//        case ToolsMenuRowOverlayTester:
//            targetClass = [OverlayTesterViewController class];
//            break;
            
        case ToolsMenuRow_MaxValue:
            break;
    }
    
    return targetClass;
}


- (id)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerDelegateAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case ToolsMenuRowAbout:
        {
            AboutMenuItems *items = [[AboutMenuItems alloc] init];
            self.aboutMenuItems = items;
            [items release];
            return self.aboutMenuItems;
            break;
        }
            
//        case ToolsMenuRowClearRemoteData:
//            break;
//            
//        case ToolsMenuRowGameTester:
//        {
//            GameTesterMenuItems *items = [[GameTesterMenuItems alloc] init];
//            self.gameTesterMenuItems = items;
//            [items release];
//            return self.gameTesterMenuItems;
//            break;
//        }
            
        case ToolsMenuRow_MaxValue:
            break;
    }
    return nil;
}


- (NSString *)menuViewControllerTitle:(JSKMenuViewController *)menuViewController
{
    return NSLocalizedString(@"Tools", @"Tools  --  title");
}

@end
