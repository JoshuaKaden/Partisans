//
//  ColorPickerViewController.h
//  Partisans
//
//  Created by Joshua Kaden on 4/26/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ColorPickerViewController;

@protocol ColorPickerViewControllerDelegate <NSObject>

- (void)colorPicked:(UIColor *)color forPicker:(ColorPickerViewController *)picker;

@end


@interface ColorPickerViewController : UIViewController

@property (nonatomic, assign) id <ColorPickerViewControllerDelegate> delegate;
@property (nonatomic, strong) UIColor *color;

- (id)initWithColor:(UIColor *)color;

@end
