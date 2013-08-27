//
//  PlayGameMenuItems.m
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

#import "PlayGameMenuItems.h"

#import "JoinGameViewController.h"
#import "SetupGameMenuItems.h"
#import "SystemMessage.h"


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


- (NSString *)menuViewControllerTitle:(JSKMenuViewController *)menuViewController
{
    return NSLocalizedString(@"Play a Game", @"Play a Game  --  title");
}

- (BOOL)menuViewControllerHidesRefreshButton:(JSKMenuViewController *)menuViewController
{
    return YES;
}

- (NSInteger)menuViewControllerNumberOfSections:(JSKMenuViewController *)menuViewController
{
    return 1;
}


- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController titleForHeaderInSection:(NSInteger)section
{
    if (![SystemMessage isWiFiAvailable])
    {
        return NSLocalizedString(@"WiFi is required, unfortunately.", @"WiFi is required, unfortunately.  --  header title");
    }
    else
    {
        return nil;
    }
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
    if (![SystemMessage isWiFiAvailable])
    {
        return nil;
    }
    
    Class targetClass = nil;
    
    switch (indexPath.row)
    {
        case PlayGameMenuRowHost:
            targetClass = [JSKMenuViewController class];
            break;
            
        case PlayGameMenuRowJoin:
            targetClass = [JoinGameViewController class];
            break;
                        
        case PlayGameMenuRow_MaxValue:
            break;
    }
    
    return targetClass;
}


- (id)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerDelegateAtIndexPath:(NSIndexPath *)indexPath
{
    if (![SystemMessage isWiFiAvailable])
    {
        return nil;
    }
    
    switch (indexPath.row)
    {
        case PlayGameMenuRowHost:
        {
            SetupGameMenuItems *items = [[SetupGameMenuItems alloc] init];
            items.shouldHost = YES;
            self.setupGameMenuItems = items;
            [items release];
            return self.setupGameMenuItems;
            break;
        }
        
        case PlayGameMenuRowJoin:
            return nil;
            break;

        case PlayGameMenuRow_MaxValue:
            return nil;
            break;
    }
    
    return nil;
}

@end
