//
//  JSKMenuViewController.h
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

#import <UIKit/UIKit.h>


// If the delegate raises this notification, the menu view controller will refresh itself.
extern NSString * const JSKMenuViewControllerShouldRefresh;


@class JSKMenuViewController;

@protocol JSKMenuViewControllerDelegate <NSObject>

// Number of sections.
- (NSInteger)menuViewControllerNumberOfSections:(JSKMenuViewController *)menuViewController;
// Number of rows in section.
- (NSInteger)menuViewController:(JSKMenuViewController *)menuViewController numberOfRowsInSection:(NSInteger)section;
// Label at index path.
- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController labelAtIndexPath:(NSIndexPath *)indexPath;
// Target view controller class at index path.
- (Class)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerClassAtIndexPath:(NSIndexPath *)indexPath;


@optional

// Did select row at index path.
- (void)menuViewController:(JSKMenuViewController *)menuViewController didSelectRowAt:(NSIndexPath *)indexPath;
// Refresh was invoked.
- (void)menuViewControllerInvokedRefresh:(JSKMenuViewController *)menuViewController;
// View did load.
- (void)menuViewControllerDidLoad:(JSKMenuViewController *)menuViewController;
// View will appear.
- (void)menuViewController:(JSKMenuViewController *)menuViewController willAppear:(BOOL)animated;
// View will disappear.
- (void)menuViewController:(JSKMenuViewController *)menuViewController willDisappear:(BOOL)animated;

// Title.
- (NSString *)menuViewControllerTitle:(JSKMenuViewController *)menuViewController;
// Sub-label at index path.
- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController subLabelAtIndexPath:(NSIndexPath *)indexPath;
// Title for header in section.
- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController titleForHeaderInSection:(NSInteger)section;
// Cell accessory view for index path.
- (UIView *)menuViewController:(JSKMenuViewController *)menuViewController cellAccessoryViewForIndexPath:(NSIndexPath *)indexPath;
// Cell accessory type for index path.
- (UITableViewCellAccessoryType)menuViewController:(JSKMenuViewController *)menuViewController cellAccessoryTypeForIndexPath:(NSIndexPath *)indexPath;
// Image for index path.
- (UIImage *)menuViewController:(JSKMenuViewController *)menuViewController imageForIndexPath:(NSIndexPath *)indexPath;
// Right button item.
- (UIBarButtonItem *)menuViewControllerRightButtonItem:(JSKMenuViewController *)menuViewController;
// Background color at index path.
- (UIColor *)menuViewController:(JSKMenuViewController *)menuViewController backgroundColorAtIndexPath:(NSIndexPath *)indexPath;
// Label color at index path.
- (UIColor *)menuViewController:(JSKMenuViewController *)menuViewController labelColorAtIndexPath:(NSIndexPath *)indexPath;
// Label font at index path.
- (UIFont *)menuViewController:(JSKMenuViewController *)menuViewController labelFontAtIndexPath:(NSIndexPath *)indexPath;

// Should auto-refresh, after initial load, on appearance?
- (BOOL)menuViewControllerShouldAutoRefresh:(JSKMenuViewController *)menuViewController;
// Should hide the back button?
- (BOOL)menuViewControllerHidesBackButton:(JSKMenuViewController *)menuViewController;
// Should hide the refresh button?
- (BOOL)menuViewControllerHidesRefreshButton:(JSKMenuViewController *)menuViewController;

// Implement this if you want a custom delegate to be applied to the target View Controller.
// This mechanism allows the selected menu item to drive the behavior of the target VC.
- (id)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerDelegateAtIndexPath:(NSIndexPath *)indexPath;

// Custom table cell.
// Please remember to use a reuse identifier when creating a custom cell.
- (UITableViewCell *)menuViewController:(JSKMenuViewController *)menuViewController tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
// Height for row at index path is useful with custom table cells.
- (CGFloat)menuViewController:(JSKMenuViewController *)menuViewController heightForRowAtIndexPath:(NSIndexPath *)indexPath;

@end


@interface JSKMenuViewController : UIViewController

@property (nonatomic, weak) id <JSKMenuViewControllerDelegate> delegate;
@property (nonatomic, strong) NSObject <JSKMenuViewControllerDelegate> *menuItems;

- (void)refresh:(BOOL)animated;
// "Refresh data" means a more thorough refresh, with a requery.
- (void)refreshData:(BOOL)animated;

// This provides a way for the delegate (or anyone) to ask this VC to close.
- (void)invokePop:(BOOL)animated;
// This provides a way for the delegate (or, indeed, anyone) to ask for a VC to be pushed.
- (void)invokePush:(BOOL)animated viewController:(UIViewController *)vc;

// Allows the caller to set the label font of a given cell.
- (void)applyLabelFont:(UIFont *)font indexPath:(NSIndexPath *)indexPath;
// Allows the caller to set the label text color of a given cell.
- (void)applyLabelColor:(UIColor *)color indexPath:(NSIndexPath *)indexPath;


@end
