//
//  JSKMenuViewController.h
//  QuestPlayer
//
//  Created by Joshua Kaden on 4/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JSKMenuViewController;

@protocol JSKMenuViewControllerDelegate <NSObject>

- (NSInteger)menuViewControllerNumberOfSections:(JSKMenuViewController *)menuViewController;
- (NSInteger)menuViewController:(JSKMenuViewController *)menuViewController numberOfRowsInSection:(NSInteger)section;
- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController labelAtIndexPath:(NSIndexPath *)indexPath;
- (Class)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerClassAtIndexPath:(NSIndexPath *)indexPath;


@optional

- (void)menuViewController:(JSKMenuViewController *)menuViewController didSelectRowAt:(NSIndexPath *)indexPath;
- (void)menuViewControllerInvokedRefresh:(JSKMenuViewController *)menuViewController;

- (NSString *)menuViewControllerTitle:(JSKMenuViewController *)menuViewController;

- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController subLabelAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)menuViewController:(JSKMenuViewController *)menuViewController titleForHeaderInSection:(NSInteger)section;

- (UIView *)menuViewController:(JSKMenuViewController *)menuViewController cellAccessoryViewForIndexPath:(NSIndexPath *)indexPath;
- (UITableViewCellAccessoryType)menuViewController:(JSKMenuViewController *)menuViewController cellAccessoryTypeForIndexPath:(NSIndexPath *)indexPath;

- (UIImage *)menuViewController:(JSKMenuViewController *)menuViewController imageForIndexPath:(NSIndexPath *)indexPath;

- (BOOL)menuViewControllerShouldAutoRefresh:(JSKMenuViewController *)menuViewController;
- (BOOL)menuViewControllerHidesBackButton:(JSKMenuViewController *)menuViewController;
- (BOOL)menuViewControllerHidesRefreshButton:(JSKMenuViewController *)menuViewController;
- (UIBarButtonItem *)menuViewControllerRightButtonItem:(JSKMenuViewController *)menuViewController;

- (UIColor *)menuViewController:(JSKMenuViewController *)menuViewController backgroundColorAtIndexPath:(NSIndexPath *)indexPath;
- (UIColor *)menuViewController:(JSKMenuViewController *)menuViewController labelColorAtIndexPath:(NSIndexPath *)indexPath;

/** Implement this if you want a custom delegate to be applied to the target View Controller.
 This mechanism allows the selected menu item to drive the behavior of the target VC.
 */
- (id)menuViewController:(JSKMenuViewController *)menuViewController targetViewControllerDelegateAtIndexPath:(NSIndexPath *)indexPath;

/** Custom table cell.
 Meteor-sized violation of the Law of Demeter here. Please remember to use a reuse identifier when creating a custom cell.
 */
- (UITableViewCell *)menuViewController:(JSKMenuViewController *)menuViewController tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)menuViewController:(JSKMenuViewController *)menuViewController heightForRowAtIndexPath:(NSIndexPath *)indexPath;


@end


@interface JSKMenuViewController : UIViewController

@property (nonatomic, assign) id <JSKMenuViewControllerDelegate> delegate;
@property (nonatomic, strong) NSObject <JSKMenuViewControllerDelegate> *menuItems;

- (void)refresh:(BOOL)animated;

// This provides a way for the delegate (or anyone) to ask this VC to close.
- (void)invokePopAnimated:(BOOL)animated;

@end
