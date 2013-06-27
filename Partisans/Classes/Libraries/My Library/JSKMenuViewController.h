//
//  JSKMenuViewController.h
//  Partisans
//
//  Created by Joshua Kaden on 4/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
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

@property (nonatomic, assign) id <JSKMenuViewControllerDelegate> delegate;
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
