//
//  MainMenuItems.m
//  QuestPlayer
//
//  Created by Joshua Kaden on 4/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "MainMenuItems.h"

#import "ImageEnvoy.h"
#import "PlayerEnvoy.h"
#import "PlayerViewController.h"
#import "SystemMessage.h"
//#import "ToolsMenuItems.h"


@interface MainMenuItems ()

//@property (nonatomic, strong) ToolsMenuItems *toolsMenuItems;

@end


@implementation MainMenuItems

//@synthesize toolsMenuItems = m_toolsMenuItems;


- (void)dealloc
{
//    [m_toolsMenuItems release];
    [super dealloc];
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
    if (section == 0)
    {
        return MainMenuRow_MaxValue;
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
        case MainMenuRowPlayer:
            label = NSLocalizedString(@"Player", @"Player  --  menu label");
            break;

        case MainMenuRowQuests:
            label = NSLocalizedString(@"Quests", @"Quests  --  menu label");
            break;
                        
        case MainMenuRowSettings:
            label = NSLocalizedString(@"Settings", @"Settings  --  menu label");
            break;
            
        case MainMenuRowTools:
            label = NSLocalizedString(@"Tools", @"Tools  --  menu label");
            break;
            
        case MainMenuRow_MaxValue:
            break;
    }
    
    return label;
}


- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController subLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section > 0)
    {
        return nil;
    }
    
    NSString *label = nil;
    
    switch (indexPath.row)
    {
        case MainMenuRowPlayer:
            label = [SystemMessage playerEnvoy].playerName;
            break;

        case MainMenuRowQuests:
            break;
            
        case MainMenuRowSettings:
        case MainMenuRowTools:
            break;
            break;

        case MainMenuRow_MaxValue:
            break;
    }
    
    return label;
}

- (UIImage *)menuViewController:(JSKMenuViewController *)menuViewController imageForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == MainMenuRowPlayer)
    {
        return [SystemMessage playerEnvoy].picture.image;
    }
    else
    {
        return nil;
    }
}


- (Class)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerClassAtIndexPath:(NSIndexPath *)indexPath
{
    Class targetClass = nil;
    
    switch (indexPath.row)
    {
        case MainMenuRowPlayer:
            targetClass = [PlayerViewController class];
            break;
        
        case MainMenuRowQuests:
        case MainMenuRowSettings:
        case MainMenuRowTools:
            targetClass = [JSKMenuViewController class];
            break;
            
        case MainMenuRow_MaxValue:
            break;
    }
    
    return targetClass;
}


- (id)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerDelegateAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case MainMenuRowPlayer:
        case MainMenuRowQuests:
        case MainMenuRowSettings:
            return nil;
            
//        case MainMenuRowTools:
//        {
//            ToolsMenuItems *items = [[ToolsMenuItems alloc] init];
//            self.toolsMenuItems =items;
//            [items release];
//            return self.toolsMenuItems;
//            break;
//        }
            
        case MainMenuRow_MaxValue:
            return nil;
            break;
    }
    
    return nil;
}


- (NSString *)menuViewControllerTitle:(JSKMenuViewController *)menuViewController
{
    return NSLocalizedString(@"Quest Player", @"Quest Player  --  title");
}


- (BOOL)menuViewControllerHidesBackButton:(JSKMenuViewController *)menuViewController
{
    return YES;
}



@end
