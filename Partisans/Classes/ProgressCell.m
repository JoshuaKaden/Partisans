//
//  ProgressCell.m
//  Darknets
//
//  Created by Joshua Kaden on 2/12/13.
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
