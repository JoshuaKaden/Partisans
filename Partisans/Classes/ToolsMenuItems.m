//
//  ToolsMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 5/23/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "ToolsMenuItems.h"

#import "AboutMenuItems.h"
#import "GameCodeViewController.h"
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
            
        case ToolsMenuRowTestEditCode:
            label = NSLocalizedString(@"Test Edit Code View", @"Test Edit Code View  --  label");
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
            
        case ToolsMenuRowTestEditCode:
            targetClass = [GameCodeViewController class];
            
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
