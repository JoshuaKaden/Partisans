//
//  PlayGameMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 5/15/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "PlayGameMenuItems.h"
#import "HostGameViewController.h"


@interface PlayGameMenuItems ()

@end


@implementation PlayGameMenuItems


- (void)dealloc
{
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
        return PlayGameMenuRow_MaxValue;
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
        case PlayGameMenuRowHost:
            label = NSLocalizedString(@"Host", @"Host  --  menu label");
            break;
            
        case PlayGameMenuRowJoin:
            label = NSLocalizedString(@"Join", @"Join  --  menu label");
            break;
            
        case PlayGameMenuRow_MaxValue:
            break;
    }
    
    return label;
}




- (Class)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerClassAtIndexPath:(NSIndexPath *)indexPath
{
    Class targetClass = nil;
    
    switch (indexPath.row)
    {
        case PlayGameMenuRowHost:
            targetClass = [HostGameViewController class];
            break;
            
        case PlayGameMenuRowJoin:
            targetClass = nil;
            break;
            
        case PlayGameMenuRow_MaxValue:
            break;
    }
    
    return targetClass;
}


//- (id)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerDelegateAtIndexPath:(NSIndexPath *)indexPath
//{
//    switch (indexPath.row)
//    {
//        case PlayGameMenuRowHost:
//        {
//            HostGameMenuItems *items = [[HostGameMenuItems alloc] init];
//            self.hostGameMenuItems = items;
//            [items release];
//            return self.hostGameMenuItems;
//            break;
//        }
//            
//        case PlayGameMenuRowJoin:
//            return nil;
//            
//        case PlayGameMenuRow_MaxValue:
//            return nil;
//            break;
//    }
//    
//    return nil;
//}



- (NSString *)menuViewControllerTitle:(JSKMenuViewController *)menuViewController
{
    return NSLocalizedString(@"Play a Game", @"Play a Game  --  title");
}

@end
