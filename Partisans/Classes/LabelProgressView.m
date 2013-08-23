//
//  ProgressView.m
//  Darknets
//
//  Created by Joshua Kaden on 2/11/13.
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

#import "LabelProgressView.h"
#import "SystemMessage.h"


@interface LabelProgressView ()

@property (nonatomic, strong) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) IBOutlet UILabel *label;
@property (nonatomic, strong) IBOutlet UILabel *spellOutLabel;
@property (nonatomic, strong) IBOutlet UIProgressView *dualProgressView;

- (void)buildSpellOutText;

@end


@implementation LabelProgressView


@synthesize progressView = m_progressView;
@synthesize label = m_label;
@synthesize spellOutLabel = m_spellOutLabel;
@synthesize isDual = m_isDual;
@synthesize dualProgressView = m_dualProgressView;
@synthesize shouldShowSpellOutText = m_shouldShowSpellOutText;


- (void)dealloc
{    
    [m_progressView release];
    [m_label release];
    [m_spellOutLabel release];
    [m_dualProgressView release];
    [super dealloc];
}



- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        UIView *mainView = [subviewArray objectAtIndex:0];
        
        //Just in case the size is different (you may or may not want this)
        mainView.frame = self.bounds;
        
        [self addSubview:mainView];
    }
    
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
        UIView *mainView = [subviewArray objectAtIndex:0];
        
        //Just in case the size is different (you may or may not want this)
        mainView.frame = self.bounds;
        
        [self addSubview:mainView];
    }
    return self;
}



- (void)setIsDual:(BOOL)isDual
{
    m_isDual = isDual;
    [self.dualProgressView setHidden:!isDual];
}


- (UIColor *)progressTintColor
{
    return self.progressView.progressTintColor;
}


- (void)setProgressTintColor:(UIColor *)progressTintColor
{
    [self.progressView setProgressTintColor:progressTintColor];
}


- (UIColor *)dualProgressTintColor
{
    return self.dualProgressView.progressTintColor;
}


- (void)setDualProgressTintColor:(UIColor *)progressTintColor
{
    [self.dualProgressView setProgressTintColor:progressTintColor];
}



- (float)progress
{
    return self.progressView.progress;
}

- (void)setProgress:(float)progress animated:(BOOL)animated
{
    [self.progressView setProgress:progress animated:animated];
    
    [self buildSpellOutText];
}


- (float)dualProgress
{
    return self.dualProgressView.progress;
}

- (void)setDualProgress:(float)progress animated:(BOOL)animated
{
    [self.dualProgressView setProgress:progress animated:animated];
    
    [self buildSpellOutText];
}


- (NSString *)labelText
{
    return self.label.text;
}

- (void)setLabelText:(NSString *)labelText
{
    [self.label setText:labelText];
}


- (void)buildSpellOutText
{
    if (!self.shouldShowSpellOutText)
    {
        [self.spellOutLabel setText:nil];
        return;
    }
    
    float progress = self.progressView.progress;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterPercentStyle];
    //    [formatter setNumberStyle:NSNumberFormatterSpellOutStyle];
    [self.spellOutLabel setText:[formatter stringFromNumber:[NSNumber numberWithFloat:progress]]];
    
    if (self.isDual)
    {
        float dualProgress = self.dualProgressView.progress;
        NSString *dualText = [formatter stringFromNumber:[NSNumber numberWithFloat:dualProgress]];
        NSString *labelText = [NSString stringWithFormat:@"%@ / %@", self.spellOutLabel.text, dualText];
        [self.spellOutLabel setText:labelText];
    }
    
    [formatter release];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/




@end
