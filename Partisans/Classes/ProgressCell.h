//
//  ProgressCell.h
//  Darknets
//
//  Created by Joshua Kaden on 2/12/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressCell : UITableViewCell

@property (nonatomic, strong) UIColor *progressTintColor;
@property (nonatomic, strong) UIColor *dualProgressTintColor;
@property (readonly) float progress;
@property (readonly) float dualProgress;
@property (readonly) NSString *progressLabelText;
@property (nonatomic, assign) BOOL isDual;

- (void)setProgress:(float)progress animated:(BOOL)animated;
- (void)setDualProgress:(float)progress animated:(BOOL)animated;
- (void)setProgressLabelText:(NSString *)labelText;

@end
