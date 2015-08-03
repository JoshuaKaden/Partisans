//
//  OperativeAlertMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 6/21/13.
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

#import "OperativeAlertMenuItems.h"

#import "GameEnvoy.h"
#import "GamePlayerEnvoy.h"
#import "ImageEnvoy.h"
#import "PlayerEnvoy.h"
#import "SystemMessage.h"


@interface OperativeAlertMenuItems ()

@property (nonatomic, assign) BOOL isOperative;
@property (nonatomic, strong) NSArray *operatives;
@property (nonatomic, assign) BOOL isMessageOpen;

@end


@implementation OperativeAlertMenuItems

@synthesize isOperative = m_isOperative;
@synthesize operatives = m_operatives;
@synthesize isMessageOpen = m_isMessageOpen;



- (NSArray *)operatives
{
    if (!m_operatives)
    {
        if (self.isOperative)
        {
            // Exclude ourselves in this case.
            NSArray *operatives = [SystemMessage gameEnvoy].operatives;
            self.operatives = [operatives filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"intramuralID != %@", [SystemMessage playerEnvoy].intramuralID]];
        }
        else
        {
            self.operatives = [SystemMessage gameEnvoy].operatives;
        }
    }
    return m_operatives;
}


#pragma mark - Menu View Controller delegate

- (void)menuViewControllerDidLoad:(JSKMenuViewController *)menuViewController
{
    self.isOperative = [[SystemMessage gameEnvoy] isPlayerAnOperative:[SystemMessage playerEnvoy]];
}

- (void)menuViewController:(JSKMenuViewController *)menuViewController didSelectRowAt:(NSIndexPath *)indexPath
{
    if (indexPath.section == OperativeAlertMenuSectionCommand)
    {
        GamePlayerEnvoy *gamePlayerEnvoy = [[SystemMessage gameEnvoy] gamePlayerEnvoyFromPlayer:[SystemMessage playerEnvoy]];
        gamePlayerEnvoy.hasAlertBeenShown = YES;
        [gamePlayerEnvoy commitAndSave];
        [menuViewController.navigationController popToRootViewControllerAnimated:NO];
    }
    
    // This is the "decrypt message" privacy button.
    if (indexPath.section == OperativeAlertMenuSectionStatus)
    {
        if (!self.isMessageOpen)
        {
            self.isMessageOpen = YES;
            [menuViewController refreshData:YES];
        }
    }
}

- (NSString *)menuViewControllerTitle:(JSKMenuViewController *)menuViewController
{
    return NSLocalizedString(@"Private", @"Private  --  title");
}

- (NSInteger)menuViewControllerNumberOfSections:(JSKMenuViewController *)menuViewController
{
    return OperativeAlertMenuSection_MaxValue;
//    if (self.isMessageOpen)
//    {
//        return OperativeAlertMenuSection_MaxValue;
//    }
//    else
//    {
//        return 1;
//    }
}

- (NSInteger)menuViewController:(JSKMenuViewController *)menuViewController numberOfRowsInSection:(NSInteger)section
{
    if (!self.isMessageOpen)
    {
        if (section == OperativeAlertMenuSectionStatus)
        {
            return 1;
        }
        else
        {
            return 0;
        }
    }
    
    if (section == OperativeAlertMenuSectionList)
    {
        return self.operatives.count;
    }
    else
    {
        return 1;
    }
}

- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController titleForHeaderInSection:(NSInteger)section
{
    if (!self.isMessageOpen)
    {
        if (section == OperativeAlertMenuSectionStatus)
        {
            return NSLocalizedString(@"Encrypted Message", @"Encrypted Message  --  title");
        }
        else
        {
            return nil;
        }
    }
    
    NSString *returnValue = nil;
    OperativeAlertMenuSection menuSection = (OperativeAlertMenuSection)section;
    switch (menuSection)
    {
        case OperativeAlertMenuSectionStatus:
            returnValue = NSLocalizedString(@"Status", @"Status  --  title");
            break;
        case OperativeAlertMenuSectionList:
            if (self.isOperative)
            {
                if (self.operatives.count == 1)
                {
                    returnValue = NSLocalizedString(@"Fellow Operative", @"Fellow Operative  --  title");
                }
                else
                {
                    returnValue = NSLocalizedString(@"Fellow Operatives", @"Fellow Operatives  --  title");
                }
            }
            else
            {
                returnValue = NSLocalizedString(@"Operatives", @"Operatives  --  title");
            }
            break;
        case OperativeAlertMenuSectionCommand:
            break;
        case OperativeAlertMenuSection_MaxValue:
            break;
    }
    return returnValue;
}

- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController labelAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isMessageOpen)
    {
        if (indexPath.section == OperativeAlertMenuSectionStatus)
        {
            return NSLocalizedString(@"Hide your screen.", @"Hide your screen.  --  label");
        }
        else
        {
            return nil;
        }
    }
    
    NSString *returnValue = nil;
    OperativeAlertMenuSection menuSection = (OperativeAlertMenuSection)indexPath.section;
    switch (menuSection)
    {
        case OperativeAlertMenuSectionStatus:
            if (self.isOperative)
            {
                returnValue = NSLocalizedString(@"You are an Operative.", @"You are an Operative.  --  label");
            }
            else
            {
                returnValue = NSLocalizedString(@"Operatives are in our midst.", @"Operatives are in our midst.  --  label");
            }
            break;
        case OperativeAlertMenuSectionList:
        {
            if (self.isOperative)
            {
                PlayerEnvoy *operative = [self.operatives objectAtIndex:indexPath.row];
                returnValue = operative.playerName;
            }
            else
            {
                returnValue = NSLocalizedString(@"<Unknown>", @"<Unknown>  --  label");
            }
            break;
        }
        case OperativeAlertMenuSectionCommand:
            returnValue = NSLocalizedString(@"Proceed", @"Proceed  --  label");
            break;
        case OperativeAlertMenuSection_MaxValue:
            break;
    }
    return returnValue;
}

- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController subLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isMessageOpen)
    {
        if (indexPath.section == OperativeAlertMenuSectionStatus)
        {
            return NSLocalizedString(@"Tap to decrypt this message.", @"Tap to decrypt this message.  --  sub label");
        }
        else
        {
            return nil;
        }
    }
    
    if (indexPath.section == OperativeAlertMenuSectionCommand)
    {
        return NSLocalizedString(@"Tap to destroy this message.", @"Tap to destroy this message.  --  sub label");
    }
    else if (indexPath.section == OperativeAlertMenuSectionStatus && self.isOperative)
    {
        NSString *prefix = NSLocalizedString(@"They know there are", @"They know there are  --  label prefix");
        NSString *suffix = NSLocalizedString(@"of you.", @"of you.  --  label suffix");
        return [NSString stringWithFormat:@"%@ %lu %@", prefix, self.operatives.count + 1, suffix];
//        NSString *numberString = [SystemMessage spellOutInteger:self.operatives.count + 1];
//        return [NSString stringWithFormat:@"%@ %@ %@", prefix, numberString, suffix];
    }
    else
    {
        return nil;
    }
}

- (UIImage *)menuViewController:(JSKMenuViewController *)menuViewController imageForIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isMessageOpen)
    {
        return nil;
    }
    
    if (indexPath.section == OperativeAlertMenuSectionList)
    {
        if (self.isOperative)
        {
            PlayerEnvoy *envoy = [self.operatives objectAtIndex:indexPath.row];
            return envoy.smallImage;
        }
        else
        {
            return [UIImage imageNamed:@"black_mask"];
        }
    }
    else if (indexPath.section == OperativeAlertMenuSectionStatus && self.isOperative)
    {
        return [UIImage imageNamed:@"black_mask"];
    }
    else
    {
        return nil;
    }
}

- (NSTextAlignment)menuViewController:(JSKMenuViewController *)menuViewController labelAlignmentAtIndexPath:(NSIndexPath *)indexPath
{
    NSTextAlignment returnValue = NSTextAlignmentLeft;
    if (indexPath.section == OperativeAlertMenuSectionCommand)
    {
        returnValue = NSTextAlignmentCenter;
    }
    return returnValue;
}

- (Class)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerClassAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (BOOL)menuViewControllerHidesBackButton:(JSKMenuViewController *)menuViewController
{
    return NO;
}

- (BOOL)menuViewControllerHidesRefreshButton:(JSKMenuViewController *)menuViewController
{
    return YES;
}

- (BOOL)menuViewControllerShouldAutoRefresh:(JSKMenuViewController *)menuViewController
{
    return NO;
}

- (UITableViewCellAccessoryType)menuViewController:(JSKMenuViewController *)menuViewController cellAccessoryTypeForIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellAccessoryNone;
}

@end
