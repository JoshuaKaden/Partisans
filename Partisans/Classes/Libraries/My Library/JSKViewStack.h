//
//  JSKViewStack.h
//  Partisans
//
//  Created by Joshua Kaden on 4/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JSKViewStack : UIView

@property (assign, nonatomic) BOOL isHorizontal;
@property (assign, nonatomic) float gutter;
@property (strong, nonatomic) UIColor *borderColor;
@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) UIColor *backgroundColor;
@property (assign, nonatomic) BOOL shouldNotShrinkToFit;

- (void)addView:(UIView *)view;
- (void)clearViews;

@end

