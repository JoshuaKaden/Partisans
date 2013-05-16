//
//  ProgressView.h
//  Darknets
//
//  Created by Joshua Kaden on 2/11/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LabelProgressView : UIView

@property (nonatomic, strong) UIColor *progressTintColor;
@property (nonatomic, strong) UIColor *dualProgressTintColor;
@property (readonly) float progress;
@property (readonly) float dualProgress;
@property (readonly) NSString *labelText;
@property (nonatomic, assign) BOOL isDual;
@property (nonatomic, assign) BOOL shouldShowSpellOutText;

- (void)setProgress:(float)progress animated:(BOOL)animated;
- (void)setDualProgress:(float)progress animated:(BOOL)animated;
- (void)setLabelText:(NSString *)labelText;

@end
