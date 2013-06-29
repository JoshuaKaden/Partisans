//
//  OperativeAlertMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 6/21/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
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

@end


@implementation OperativeAlertMenuItems

@synthesize isOperative = m_isOperative;
@synthesize operatives = m_operatives;

- (void)dealloc
{
    [m_operatives release];
    [super dealloc];
}

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
}

- (NSString *)menuViewControllerTitle:(JSKMenuViewController *)menuViewController
{
    return NSLocalizedString(@"Encrypted Message", @"Encrypted Message  --  title");
}

- (NSInteger)menuViewControllerNumberOfSections:(JSKMenuViewController *)menuViewController
{
    return OperativeAlertMenuSection_MaxValue;
}

- (NSInteger)menuViewController:(JSKMenuViewController *)menuViewController numberOfRowsInSection:(NSInteger)section
{
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
    NSString *returnValue = nil;
    OperativeAlertMenuSection menuSection = (OperativeAlertMenuSection)indexPath.section;
    switch (menuSection)
    {
        case OperativeAlertMenuSectionStatus:
            if (self.isOperative)
            {
                returnValue = NSLocalizedString(@"You are an Operative", @"You are an Operative  --  title");
            }
            else
            {
                returnValue = NSLocalizedString(@"Operatives are in our midst", @"Operatives are in our midst  --  title");
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
    if (indexPath.section == OperativeAlertMenuSectionCommand)
    {
        return NSLocalizedString(@"Tap to destroy this message", @"Tap to destroy this message  --  sublabel");
    }
    else
    {
        return nil;
    }
}

- (UIImage *)menuViewController:(JSKMenuViewController *)menuViewController imageForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == OperativeAlertMenuSectionList)
    {
        if (self.isOperative)
        {
            PlayerEnvoy *envoy = [self.operatives objectAtIndex:indexPath.row];
            return envoy.picture.image;
        }
        else
        {
            return [UIImage imageNamed:@"black_mask"];
        }
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
    return YES;
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
