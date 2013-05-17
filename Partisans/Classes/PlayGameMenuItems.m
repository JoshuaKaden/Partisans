//
//  PlayGameMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 5/15/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "PlayGameMenuItems.h"
#import "SetupGameMenuItems.h"


@interface PlayGameMenuItems ()

@property (nonatomic, strong) SetupGameMenuItems *setupGameMenuItems;

@end


@implementation PlayGameMenuItems

@synthesize setupGameMenuItems = m_setupGameMenuItems;

- (void)dealloc
{
    [m_setupGameMenuItems release];
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
        case PlayGameMenuRowJoin:
            targetClass = [JSKMenuViewController class];
            break;
                        
        case PlayGameMenuRow_MaxValue:
            break;
    }
    
    return targetClass;
}


- (id)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerDelegateAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case PlayGameMenuRowHost:
        case PlayGameMenuRowJoin:
        {
            SetupGameMenuItems *items = [[SetupGameMenuItems alloc] init];
            self.setupGameMenuItems = items;
            [items release];
            return self.setupGameMenuItems;
            break;
        }

        case PlayGameMenuRow_MaxValue:
            return nil;
            break;
    }
    
    return nil;
}



- (NSString *)menuViewControllerTitle:(JSKMenuViewController *)menuViewController
{
    return NSLocalizedString(@"Play a Game", @"Play a Game  --  title");
}

@end
