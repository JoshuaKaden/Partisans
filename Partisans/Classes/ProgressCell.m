//
//  ProgressCell.m
//  Darknets
//
//  Created by Joshua Kaden on 2/12/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "ProgressCell.h"
#import "LabelProgressView.h"


@interface ProgressCell ()

@property (nonatomic, strong) IBOutlet LabelProgressView *labelProgressView;

@end


@implementation ProgressCell


@synthesize labelProgressView = m_labelProgressView;



- (void)dealloc
{
    [m_labelProgressView release];
    [super dealloc];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



- (BOOL)isDual
{
    return self.labelProgressView.isDual;
}

- (void)setIsDual:(BOOL)isDual
{
    [self.labelProgressView setIsDual:isDual];
}


- (UIColor *)progressTintColor {
    
    return self.labelProgressView.progressTintColor;
}


- (void)setProgressTintColor:(UIColor *)progressTintColor {
    
    [self.labelProgressView setProgressTintColor:progressTintColor];
}


- (UIColor *)dualProgressTintColor {
    
    return self.labelProgressView.dualProgressTintColor;
}


- (void)setDualProgressTintColor:(UIColor *)progressTintColor {
    
    [self.labelProgressView setDualProgressTintColor:progressTintColor];
}



- (float)progress {
    
    return self.labelProgressView.progress;
}

- (void)setProgress:(float)progress animated:(BOOL)animated {
    
    [self.labelProgressView setProgress:progress animated:animated];
}


- (float)dualProgress {
    
    return self.labelProgressView.dualProgress;
}

- (void)setDualProgress:(float)progress animated:(BOOL)animated {
    
    [self.labelProgressView setDualProgress:progress animated:animated];
}


- (NSString *)progressLabelText {
    
    return self.labelProgressView.labelText;
}

- (void)setProgressLabelText:(NSString *)labelText {
    
    [self.labelProgressView setLabelText:labelText];
}



@end
