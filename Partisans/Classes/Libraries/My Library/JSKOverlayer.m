//
//  JSKOverlayer.h
//
//  Created by Joshua Kaden on 6/28/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "JSKOverlayer.h"
#import "SystemMessage.h"
#import <QuartzCore/QuartzCore.h>


@interface JSKOverlayer ()

@property (nonatomic, retain) UILabel * loadingLabel;
@property (nonatomic, retain) UIImageView * backgroundImageView;
@property (nonatomic, retain) UIActivityIndicatorView * spinner;

- (void)stopSpinner;
- (void)startSpinner;
- (void)updateWaitOverlayTextInDueTime:(NSString *)text;

@end


@implementation JSKOverlayer

@synthesize view = m_view;
@synthesize loadingLabel = m_loadingLabel;
@synthesize backgroundImageView = m_backgroundImageView;
@synthesize spinner = m_spinner;


- (void)dealloc {
    
    self.loadingLabel = nil;
    self.backgroundImageView = nil;
    self.spinner = nil;
    
    [m_loadingLabel release];
    [m_backgroundImageView release];
    [m_spinner release];
    [super dealloc];
}




- (id)initWithView:(UIView *)view {
    
    self = [super init];
    if (self) {
        self.view = view;
    }
    return self;
}



- (void)updateWaitOverlayText:(NSString *)text {
    
    [NSThread detachNewThreadSelector:@selector(updateWaitOverlayTextInDueTime:) toTarget:self withObject:text];
}


- (void)updateWaitOverlayTextInDueTime:(NSString *)text {
    
    self.loadingLabel.text = text;
}


- (void)createWaitOverlayWithText:(NSString *)text {
        
    // fade the overlay in
    
    if (!self.loadingLabel) {
        
        CGFloat labelW = 550.0f;
        CGFloat labelH = 130.0f;
        CGFloat labelY = 310.0f;
        if (![SystemMessage isPad]) {
            labelW = 200.0f;
            labelH = 100.0f;
            labelY = 100.0f;
        }
        
        CGFloat labelX = (self.view.bounds.size.width / 2.0f) - (labelW / 2.0f);
        CGRect labelFrame = CGRectMake(labelX, labelY, labelW, labelH);
        UILabel *loadingLabel = [[UILabel alloc] initWithFrame:labelFrame];
        loadingLabel.backgroundColor = [UIColor clearColor];
        [loadingLabel setOpaque:NO];
        loadingLabel.textColor = [UIColor whiteColor];
        [loadingLabel setTextAlignment:NSTextAlignmentCenter];
        loadingLabel.font = [UIFont boldSystemFontOfSize:19.0f];
        loadingLabel.numberOfLines = 0;
        loadingLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.loadingLabel = loadingLabel;
        [loadingLabel release];
    }
    
    self.loadingLabel.text = text;
    
//    self.loadingLabel.layer.borderColor = [[UIColor redColor] CGColor];
//    self.loadingLabel.layer.borderWidth = 1.0f;

    
    if (!self.backgroundImageView) {
        
        CGRect backgroundImageViewFrame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:backgroundImageViewFrame];
        backgroundImageView.image = [UIImage imageNamed:@"waitOverLay.png"];
        self.backgroundImageView = backgroundImageView;
        [backgroundImageView release];
    }
    
    [self.view addSubview:self.backgroundImageView];
    self.backgroundImageView.alpha = 0;
    
    [self.backgroundImageView addSubview:self.loadingLabel];
    self.loadingLabel.alpha = 0;
    
    
    [UIView beginAnimations: @"Fade In" context:nil];
    [UIView setAnimationDelay:0];
    [UIView setAnimationDuration:.5];
    self.backgroundImageView.alpha = 1;
    self.loadingLabel.alpha = 1;
    [UIView commitAnimations];
    
    [self startSpinner];    
}


- (void)removeWaitOverlay {
    
    //fade the overlay out
    
    [UIView beginAnimations: @"Fade Out" context:nil];
    [UIView setAnimationDelay:0];
    [UIView setAnimationDuration:.5];
    self.backgroundImageView.alpha = 0;
    self.loadingLabel.alpha = 0;
    [UIView commitAnimations];
    
    [self stopSpinner];
}


-(void)startSpinner {
    
    if (!self.spinner) {
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.hidden = FALSE;
        CGRect loadingLabelFrame = self.loadingLabel.frame;
        spinner.frame = CGRectMake(loadingLabelFrame.origin.x + (loadingLabelFrame.size.width / 2.0f) - 25.0f, 
                                   loadingLabelFrame.origin.y + loadingLabelFrame.size.height, 50.0f, 50.0f);
        [spinner setHidesWhenStopped:YES];
        
        self.spinner = spinner;
        [spinner release];
    }
    
    [self.view addSubview:self.spinner];
    [self.view bringSubviewToFront:self.spinner];
    [self.spinner startAnimating];
}


-(void)stopSpinner {
    
    [self.spinner stopAnimating];
    [self.spinner removeFromSuperview];
}

@end
