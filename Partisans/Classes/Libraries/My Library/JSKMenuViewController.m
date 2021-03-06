//
//  JSKMenuViewController.m
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

#import "JSKMenuViewController.h"
#import <QuartzCore/QuartzCore.h>


NSString * const JSKMenuViewControllerShouldRefresh = @"JSKMenuViewControllerShouldRefresh";


@interface JSKMenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSUInteger sectionCount;
@property (nonatomic, strong) NSMutableArray *rowCounts;
@property (nonatomic, strong) UIBarButtonItem *rightButtonItem;
@property (nonatomic, assign) BOOL hasDataBeenPresented;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isVisible;

- (void)refreshButtonPressed:(id)sender;
- (void)createRows:(BOOL)animated;
- (void)createRowsDelayed:(NSNumber *)animated;
- (void)resetLocalCounters;
- (void)shouldRefreshNotificationFired:(NSNotification *)notification;
- (void)initializeRowCounts;
- (BOOL)isPad;

@end



@implementation JSKMenuViewController

@synthesize delegate = m_delegate;
@synthesize menuItems = m_menuItems;
@synthesize sectionCount = m_sectionCount;
@synthesize rowCounts = m_rowCounts;
@synthesize rightButtonItem = m_rightButtonItem;
@synthesize hasDataBeenPresented = m_hasDataBeenPresented;
@synthesize isRefreshing = m_isRefreshing;
@synthesize isVisible = m_isVisible;



#pragma mark - View lifecycle


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if (self.menuItems)
    {
        [self setDelegate:self.menuItems];
    }
    
    
    if ([self.delegate respondsToSelector:@selector(menuViewControllerRightButtonItem:)])
    {
        self.rightButtonItem = [self.delegate menuViewControllerRightButtonItem:self];
        [self.navigationItem setRightBarButtonItem:self.rightButtonItem];
    }
    
    
    if ([self.delegate respondsToSelector:@selector(menuViewControllerHidesBackButton:)])
    {
        BOOL hidesBackButton = [self.delegate menuViewControllerHidesBackButton:self];
        [self.navigationItem setHidesBackButton:hidesBackButton];
    }
    
    
    if ([self.delegate respondsToSelector:@selector(menuViewControllerTitle:)])
    {
        if ([self.delegate menuViewControllerTitle:self])
        {
            self.title = [self.delegate menuViewControllerTitle:self];
        }
    }
    
    
    CGRect frame = self.view.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    
    
    
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    
    [self initializeRowCounts];
    
    [self refresh:YES];
    
    if ([self.delegate respondsToSelector:@selector(menuViewControllerDidLoad:)])
    {
        [self.delegate menuViewControllerDidLoad:self];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldRefreshNotificationFired:) name:JSKMenuViewControllerShouldRefresh object:nil];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRect frame = self.view.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    [self.tableView setFrame:frame];

    if (self.hasDataBeenPresented)
    {
        if ([self.delegate respondsToSelector:@selector(menuViewControllerShouldAutoRefresh:)])
        {
            if ([self.delegate menuViewControllerShouldAutoRefresh:self])
            {
                if ([self.delegate respondsToSelector:@selector(menuViewControllerInvokedRefresh:)])
                {
                    [self.delegate menuViewControllerInvokedRefresh:self];
                }
                [self refresh:NO];
            }
        }
    }
    
    self.hasDataBeenPresented = YES;
    
    if ([self.delegate respondsToSelector:@selector(menuViewController:willAppear:)])
    {
        [self.delegate menuViewController:self willAppear:animated];
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.isVisible = YES;
    
    // On the iPad, if started in landscape, the menu sits at portrait width.
    // Let's fix that.
    if ([self isPad])
    {
        if (self.tableView.frame.size.width == self.view.frame.size.width)
        {
            return;
        }
        CGRect frame = self.view.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        [self.tableView setFrame:frame];
    }
}



- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    CGRect frame = self.view.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    [self.tableView setFrame:frame];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.isVisible = NO;
//    if ([self.delegate respondsToSelector:@selector(menuViewController:willDisappear:)])
//    {
//        [self.delegate menuViewController:self willDisappear:animated];
//    }
}


- (BOOL)isPad
{
#ifdef UI_USER_INTERFACE_IDIOM
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#else
    return NO;
#endif
}


- (void)initializeRowCounts
{
    NSUInteger sectionCount = [self.delegate menuViewControllerNumberOfSections:self];
    NSMutableArray *rowCounts = [[NSMutableArray alloc] initWithCapacity:sectionCount];
    self.rowCounts = rowCounts;
    
    NSUInteger sectionIndex = 0;
    while (sectionIndex < sectionCount)
    {
        NSNumber *number = [NSNumber numberWithUnsignedInt:0];
        [self.rowCounts addObject:number];
        sectionIndex++;
    }
}



- (void)shouldRefreshNotificationFired:(NSNotification *)notification
{
    if (!self.isVisible)
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshData:NO];
    });
}


- (void)resetLocalCounters
{
    self.sectionCount = 0;
    if (self.rowCounts)
    {
        for (NSUInteger index = 0; self.rowCounts.count - 1; index++)
        {
            NSNumber *zeroNumber = [NSNumber numberWithInt:0];
            [self.rowCounts replaceObjectAtIndex:index withObject:zeroNumber];
        }
    }
}

- (void)refreshButtonPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(menuViewControllerInvokedRefresh:)])
    {
        [self.delegate menuViewControllerInvokedRefresh:self];
    }
    [self refreshData:YES];
}

- (void)refresh:(BOOL)animated
{
    if (self.isRefreshing)
    {
        return;
    }
    
    self.isRefreshing = YES;
    
    if (animated)
    {
//        [self.tableView beginUpdates];
        [self removeAllSectionsWithAnimation:UITableViewRowAnimationFade];
//        [self.tableView endUpdates];
        [self performSelector:@selector(createRowsDelayed:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.3];
        [self showLoadingIndicator];
        return;
    }
    
    [self removeAllSectionsWithAnimation:UITableViewRowAnimationFade];
    [self createRows:NO];
}


- (void)refreshData:(BOOL)animated
{
    [self initializeRowCounts];
    [self refresh:animated];
}


- (void)createRowsDelayed:(NSNumber *)animated
{
    BOOL isAnimated = [animated boolValue];
    [self createRows:isAnimated];
}


- (void)createRows:(BOOL)animated
{
//    if ([self.tableView numberOfSections] > 0)
//    {
//        // Bad news.
//        // Probably an issue with a mismatch between the data source and the local row/section counts.
//    }
    
    self.sectionCount = 0;
    
    NSUInteger sectionCount = [self.delegate menuViewControllerNumberOfSections:self];
    NSUInteger sectionIndex = 0;
    
    while (sectionIndex < sectionCount)
    {
        NSUInteger rowCount = [self.delegate menuViewController:self numberOfRowsInSection:sectionIndex];
        NSUInteger rowIndex = 0;
        [self.rowCounts replaceObjectAtIndex:sectionIndex withObject:[NSNumber numberWithInt:0]];
        
        [self.tableView beginUpdates];
        [self addSectionAtIndex:sectionIndex withAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
        [self.tableView beginUpdates];
        
        while (rowIndex < rowCount)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
            if (animated)
            {
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                      withRowAnimation:(rowIndex % 2) == 0 ? UITableViewRowAnimationLeft : UITableViewRowAnimationRight];
            }
            else
            {
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }

            NSNumber *rowCountNumber = [NSNumber numberWithUnsignedInteger:rowIndex + 1];
            [self.rowCounts replaceObjectAtIndex:sectionIndex withObject:rowCountNumber];
            
            rowIndex++;
        }
        
        [self.tableView endUpdates];
//        }
//        else
//        {
//            [self.tableView beginUpdates];
//            [self addSectionAtIndex:sectionIndex withAnimation:UITableViewRowAnimationFade];
//
//            NSUInteger rowCount = [self.delegate menuViewController:self numberOfRowsInSection:sectionIndex];
//            [self.rowCounts replaceObjectAtIndex:sectionIndex withObject:[NSNumber numberWithUnsignedInteger:rowCount]];
//            [self.tableView endUpdates];
//            
//            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//        }
        
        sectionIndex++;
    }
    
    if (animated)
    {
        [self hideLoadingIndicator];
    }
    
    self.isRefreshing = NO;
}


- (void)invokePop:(BOOL)animated
{
    [self.navigationController popViewControllerAnimated:animated];
}

- (void)invokePush:(BOOL)animated viewController:(UIViewController *)vc
{
    [self.navigationController pushViewController:vc animated:animated];
}

- (void)applyLabelFont:(UIFont *)font indexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell.textLabel setFont:font];
}

- (void)applyLabelColor:(UIColor *)color indexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell.textLabel setTextColor:color];
}

#pragma mark - Loading indicator

- (void)showLoadingIndicator
{
    if (self.rightButtonItem)
    {
        return;
    }
    
	UIActivityIndicatorView *indicator =
    [[UIActivityIndicatorView alloc]
      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	indicator.frame = CGRectMake(0, 0, 24, 24);
	[indicator startAnimating];
	UIBarButtonItem *progress =
    [[UIBarButtonItem alloc] initWithCustomView:indicator];
	[self.navigationItem setRightBarButtonItem:progress animated:YES];
}

- (void)hideLoadingIndicator
{
    if (self.rightButtonItem)
    {
        return;
    }
    
	UIActivityIndicatorView *indicator =
    (UIActivityIndicatorView *)self.navigationItem.rightBarButtonItem;
	if ([indicator isKindOfClass:[UIActivityIndicatorView class]])
	{
		[indicator stopAnimating];
	}
    
    if ([self.delegate respondsToSelector:@selector(menuViewControllerHidesRefreshButton:)])
    {
        BOOL shouldHideRefreshButton = [self.delegate menuViewControllerHidesRefreshButton:self];
        if (shouldHideRefreshButton)
        {
            [self.navigationItem setRightBarButtonItem:self.rightButtonItem animated:YES];
            return;
        }
    }

    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:refreshButton];
    
//	UIBarButtonItem *refreshButton =
//    [[[UIBarButtonItem alloc]
//      initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
//      target:self
//      action:@selector(refreshButtonPressed:)]
//     autorelease];
//	[self.navigationItem setRightBarButtonItem:refreshButton animated:YES];
}



#pragma mark - Add/Remove sections

//
// addSectionAtIndex:
//
// Adds a section object at the index. NSMutableArray will give an exception
// if the index is out of the tableSection bounds.
//
// Parameters:
//    aSectionIndex - the index of the new section
//    animation - the animation to use for the operation
//
- (void)addSectionAtIndex:(NSInteger)aSectionIndex withAnimation:(UITableViewRowAnimation)animation
{
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:aSectionIndex]
                  withRowAnimation:animation];
    self.sectionCount++;
}


//
// removeSectionAtIndex:
//
// Removes all the rows in a section
//
// Parameters:
//    aSectionIndex - section index for removal
//    animation - the animation to use for the operation
//
- (void)removeSectionAtIndex:(NSInteger)aSectionIndex
               withAnimation:(UITableViewRowAnimation)animation
{
	if ((NSUInteger)aSectionIndex >= [self.delegate menuViewControllerNumberOfSections:self])
	{
		return;
	}
    
    [self.tableView beginUpdates];
    
    [self.tableView
     deleteSections:[NSIndexSet indexSetWithIndex:aSectionIndex]
     withRowAnimation:animation];
    
    NSNumber *rowCountNumber = [NSNumber numberWithUnsignedInt:0];
    [self.rowCounts replaceObjectAtIndex:aSectionIndex withObject:rowCountNumber];
    
    self.sectionCount--;
    
    [self.tableView endUpdates];
}

//
// removeAllSectionsWithAnimation:
//
// Removes all the rows in a section
//
// Parameters:
//    aSectionIndex - section index for removal
//    animation - the animation to use for the operation
//
- (void)removeAllSectionsWithAnimation:(UITableViewRowAnimation)animation
{
    if ([self.tableView numberOfSections] == 0)
    {
        return;
    }
    
    [self.tableView beginUpdates];
    
    NSUInteger sectionCount = [self.delegate menuViewControllerNumberOfSections:self];
    
    NSInteger sectionIndex = sectionCount - 1;
    while (sectionIndex > -1)
	{
		[self removeSectionAtIndex:sectionIndex withAnimation:animation];
        sectionIndex--;
	}
    
    [self.tableView endUpdates];
}

////
//// removeRowAtIndex:inSection:withAnimation:
////
//// Removes all the rows in a section
////
//// Parameters:
////    aSectionIndex - section index for removal
////    animation - the animation to use for the operation (specifying
////		UITableViewRowAnimationNone will prevent the update entirely)
////
//- (void)removeRowAtIndex:(NSInteger)aRowIndex inSection:(NSInteger)aSectionIndex
//           withAnimation:(UITableViewRowAnimation)animation
//{
//	if ((NSUInteger)aSectionIndex >= [self.delegate menuViewControllerNumberOfSections:self])
//	{
//		return;
//	}
//	
//	if ((NSUInteger)aRowIndex >= [self.delegate menuViewController:self numberOfRowsInSection:aSectionIndex])
//	{
//		return;
//	}
//	
//	if (animation != UITableViewRowAnimationNone)
//	{
//		[self.tableView
//         deleteRowsAtIndexPaths:
//         [NSArray arrayWithObject:
//          [NSIndexPath indexPathForRow:aRowIndex inSection:aSectionIndex]]
//         withRowAnimation:animation];
//	}
//}



#pragma mark - Table


// Many thanks to TonnyXu for the heart of the corner-rounding code!
// https://gist.github.com/TonnyXu/1729463
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(menuViewController:imageForIndexPath:)])
    {
        UIImage *cellImage = [self.delegate menuViewController:self imageForIndexPath:indexPath];
        if (!cellImage)
        {
            // We can skip all the corner rounding stuff if there's no cell image.
            return;
        }
    }
    
    NSUInteger rowCount = [self.delegate menuViewController:self numberOfRowsInSection:indexPath.section];
    
    if (rowCount == 0)
    {
        // Weird? Shouldn't happen.
        return;
    }
    
    if (rowCount == 1)
    {
        // Just round all corners and be done with it.
        cell.contentView.layer.cornerRadius = 8.0f;
        cell.contentView.layer.masksToBounds = YES;
        return;
    }
    
    if (indexPath.row == 0)
    {
        // first row
        CGRect cellRect = cell.contentView.bounds;
        CGMutablePathRef firstRowPath = CGPathCreateMutable();
        CGPathMoveToPoint(firstRowPath, NULL, CGRectGetMinX(cellRect), CGRectGetMaxY(cellRect));
        CGPathAddLineToPoint(firstRowPath, NULL, CGRectGetMinX(cellRect), 8.f);
        CGPathAddArcToPoint(firstRowPath, NULL, CGRectGetMinX(cellRect), CGRectGetMinY(cellRect), 8.f, CGRectGetMinY(cellRect), 8.f);
        CGPathAddLineToPoint(firstRowPath, NULL, CGRectGetMaxX(cellRect) - 8.f, 0.f);
        CGPathAddArcToPoint(firstRowPath, NULL, CGRectGetMaxX(cellRect), CGRectGetMinY(cellRect), CGRectGetMaxX(cellRect), 8.f, 8.f);
        CGPathAddLineToPoint(firstRowPath, NULL, CGRectGetMaxX(cellRect), CGRectGetMaxY(cellRect));
        CGPathCloseSubpath(firstRowPath);
        
        CAShapeLayer *newSharpLayer = [[CAShapeLayer alloc] init];
        newSharpLayer.path = firstRowPath;
        newSharpLayer.fillColor = [[UIColor whiteColor] colorWithAlphaComponent:1.f].CGColor;
        CFRelease(firstRowPath);
        
        cell.contentView.layer.mask = newSharpLayer;
    }
    else if (indexPath.row == rowCount - 1)
    {
        // last row
        CGRect cellRect = cell.contentView.bounds;
        CGMutablePathRef lastRowPath = CGPathCreateMutable();
        CGPathMoveToPoint(lastRowPath, NULL, CGRectGetMinX(cellRect), CGRectGetMinY(cellRect));
        CGPathAddLineToPoint(lastRowPath, NULL, CGRectGetMaxX(cellRect), CGRectGetMinY(cellRect));
        CGPathAddLineToPoint(lastRowPath, NULL, CGRectGetMaxX(cellRect), CGRectGetMaxY(cellRect) - 8.f);
        CGPathAddArcToPoint(lastRowPath, NULL, CGRectGetMaxX(cellRect), CGRectGetMaxY(cellRect), CGRectGetMaxX(cellRect)- 8.f, CGRectGetMaxY(cellRect), 8.f);
        CGPathAddLineToPoint(lastRowPath, NULL, 8.f, CGRectGetMaxY(cellRect));
        CGPathAddArcToPoint(lastRowPath, NULL, CGRectGetMinX(cellRect), CGRectGetMaxY(cellRect), CGRectGetMinX(cellRect), CGRectGetMaxY(cellRect) - 8.f, 8.f);
        CGPathCloseSubpath(lastRowPath);
        
        CAShapeLayer *newSharpLayer = [[CAShapeLayer alloc] init];
        newSharpLayer.path = lastRowPath;
        newSharpLayer.fillColor = [[UIColor whiteColor] colorWithAlphaComponent:1.f].CGColor;
        CFRelease(lastRowPath);
        
        cell.contentView.layer.mask = newSharpLayer;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(menuViewController:heightForRowAtIndexPath:)])
    {
        return [self.delegate menuViewController:self heightForRowAtIndexPath:indexPath];
    }
    else
    {
        return 44.0f;
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sectionCount;
    //    // Return the number of sections.
    //    if (!self.delegate) {
    //        return 0;
    //    }
    //    return [self.delegate menuViewControllerNumberOfSections:self];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = [[self.rowCounts objectAtIndex:section] integerValue];
    return rows;
    //    // Return the number of rows in the section.
    //    if (!self.delegate) {
    //        return 0;
    //    }
    //    return [self.delegate menuViewController:self numberOfRowsInSection:section];
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(menuViewController:titleForHeaderInSection:)])
    {
        return [self.delegate menuViewController:self titleForHeaderInSection:section];
    }
    return nil;
}



// This code is erroring out for some reason.

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *returnValue = nil;
//    CGRect frame = CGRectMake(10.0f, 0.0f, 160.0f, 21.0f);
//    UILabel *label = [[UILabel alloc] initWithFrame:frame];
//    if ([self.delegate respondsToSelector:@selector(menuViewController:titleForHeaderInSection:)])
//    {
//        NSString *text = [self.delegate menuViewController:self titleForHeaderInSection:section];
//        label.text = text;
//        [label setFont:[UIFont fontWithName:@"GillSans" size:18]];
//    }
//    returnValue = label;
//    [label release];
//    return returnValue;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 21.0f;
//}



// Customize the appearance of table view cells.

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // This is to allow the delegate to supply a custom table cell.
    // Breaking the Law of Demeter rather flagrantly here:
    // The delegate has the responsibility of properly reusing the cells.
    if ([self.delegate respondsToSelector:@selector(menuViewController:tableView:cellForRowAtIndexPath:)])
    {
        UITableViewCell *cell = [self.delegate menuViewController:self tableView:tableView cellForRowAtIndexPath:indexPath];
        if (cell) {
            return cell;
        }
    }
    
    
    // This is the default cell creation for standard menus.
    static NSString *CellIdentifier = @"JSKMenuCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
//		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    
    cell.textLabel.text = [self.delegate menuViewController:self labelAtIndexPath:indexPath];
    
    if ([self.delegate respondsToSelector:@selector(menuViewController:subLabelAtIndexPath:)])
    {
        cell.detailTextLabel.text = [self.delegate menuViewController:self subLabelAtIndexPath:indexPath];
    }
    
    if ([self.delegate respondsToSelector:@selector(menuViewController:cellAccessoryTypeForIndexPath:)])
    {
        cell.accessoryType = [self.delegate menuViewController:self cellAccessoryTypeForIndexPath:indexPath];
    }
    else
    {
        // The good old disclosure indicator is the default.
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if ([self.delegate respondsToSelector:@selector(menuViewController:cellAccessoryViewForIndexPath:)])
    {
        cell.accessoryView = [self.delegate menuViewController:self cellAccessoryViewForIndexPath:indexPath];
    }
    
    [cell.imageView setImage:nil];
    if ([self.delegate respondsToSelector:@selector(menuViewController:imageForIndexPath:)])
    {
        UIImage *cellImage = [self.delegate menuViewController:self imageForIndexPath:indexPath];
        if (cellImage)
        {
//            // Rounded corners on the image.
//            cell.imageView.layer.masksToBounds = YES;
//            cell.imageView.layer.cornerRadius = 5.0;
            [cell.imageView setImage:[self.delegate menuViewController:self imageForIndexPath:indexPath]];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(menuViewController:labelColorAtIndexPath:)])
    {
        [cell.textLabel setTextColor:[self.delegate menuViewController:self labelColorAtIndexPath:indexPath]];
    }
    
    if ([self.delegate respondsToSelector:@selector(menuViewController:backgroundColorAtIndexPath:)])
    {
        [cell.contentView setBackgroundColor:[self.delegate menuViewController:self backgroundColorAtIndexPath:indexPath]];
    }
    

    CGFloat size = 18.0f;
    UIFont *font = [UIFont fontWithName:@"GillSans" size:size];
    [cell.textLabel setFont:font];
    
    if ([self.delegate respondsToSelector:@selector(menuViewController:labelFontAtIndexPath:)])
    {
        UIFont *font = [self.delegate menuViewController:self labelFontAtIndexPath:indexPath];
        if (font)
        {
            [cell.textLabel setFont:font];
        }
    }
    
    UIFont *subFont = [UIFont fontWithName:@"GillSans" size:14.0f];
    [cell.detailTextLabel setFont:subFont];
    
    
    
    return cell;
}






#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate)
    {
        if ([self.delegate respondsToSelector:@selector(menuViewController:didSelectRowAt:)])
        {
            [self.delegate menuViewController:self didSelectRowAt:indexPath];
        }
        
        Class targetClass = [self.delegate menuViewController:self targetViewControllerClassAtIndexPath:indexPath];
        if (targetClass)
        {
            UIViewController *targetViewController = [[targetClass alloc] init];
            
            if ([self.delegate respondsToSelector:@selector(menuViewController:targetViewControllerDelegateAtIndexPath:)])
            {
                id delegate = [self.delegate menuViewController:self targetViewControllerDelegateAtIndexPath:indexPath];
                
                if ([targetViewController respondsToSelector:@selector(delegate)])
                {
                    [targetViewController setValue:delegate forKey:@"delegate"];
                }
            }
            
            [self.navigationController pushViewController:targetViewController animated:YES];
        }
    }
    
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}





@end
