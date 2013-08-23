//
//  AboutMenuItems.m
//  Partisans
//
//  Created by Joshua Kaden on 7/12/13.
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

#import "AboutMenuItems.h"

@implementation AboutMenuItems


#pragma mark - Menu View Controller delegate

- (NSString *)menuViewControllerTitle:(JSKMenuViewController *)menuViewController
{
    NSString *title = NSLocalizedString(@"About", @"About  --  title");
    return title;
}

- (NSInteger)menuViewControllerNumberOfSections:(JSKMenuViewController *)menuViewController
{
    return 1;
}

- (NSInteger)menuViewController:(JSKMenuViewController *)menuViewController numberOfRowsInSection:(NSInteger)section
{
    return AboutRow_MaxValue;
}

- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController labelAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *returnValue = nil;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    AboutRow menuRow = (AboutRow)indexPath.row;
    switch (menuRow)
    {
        case AboutRowName:
            returnValue = [infoDictionary objectForKey:@"CFBundleDisplayName"];
            break;
        case AboutRowVersion:
            returnValue = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
            break;
        case AboutRowBuild:
            returnValue = [infoDictionary objectForKey:@"CFBundleVersion"];
            break;
        case AboutRow_MaxValue:
            break;
    }
    return returnValue;
}

- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController subLabelAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *returnValue = nil;
    AboutRow menuRow = (AboutRow)indexPath.row;
    switch (menuRow)
    {
        case AboutRowName:
//            returnValue = NSLocalizedString(@"Name", @"Name  --  sub label");
            break;
        case AboutRowVersion:
            returnValue = NSLocalizedString(@"Version", @"Version  --  sub label");
            break;
        case AboutRowBuild:
            returnValue = NSLocalizedString(@"Build", @"Build  --  sub label");
            break;
        case AboutRow_MaxValue:
            break;
    }
    return returnValue;
}

- (UIImage *)menuViewController:(JSKMenuViewController *)menuViewController imageForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == AboutRowName)
    {
        return [UIImage imageNamed:@"Icon"];
    }
    else
    {
        return nil;
    }
}

- (Class)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerClassAtIndexPath:(NSIndexPath *)indexPath
{
    Class returnValue = nil;
    return returnValue;
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
