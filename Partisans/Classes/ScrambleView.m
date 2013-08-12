//
//  ScrambleView.m
//  Partisans
//
//  Created by Joshua Kaden on 8/12/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "ScrambleView.h"


@interface ScrambleView ()

@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@end


@implementation ScrambleView

@synthesize imageView = m_imageView;


- (void)dealloc
{
    self.imageView.image = nil;
    
    [m_imageView release];
    
    [super dealloc];
}


#pragma mark - Passthrough accessors

- (UIImage *)image
{
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image
{
    [self.imageView setImage:image];
}


#pragma mark - XIB association boilerplate

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

@end
