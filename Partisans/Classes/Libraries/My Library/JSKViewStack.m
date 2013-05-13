//
//  JSKViewStack.m
//  QuestPlayer
//
//  Created by Joshua Kaden on 4/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "JSKViewStack.h"
#import <QuartzCore/QuartzCore.h>


@interface JSKViewStack ()

@property (strong, nonatomic) NSMutableArray *views;
@property (assign, nonatomic) CGPoint nextOrigin;

- (void)resizeFrame;

@end


@implementation JSKViewStack

@synthesize isHorizontal = m_isHorizontal;
@synthesize views = m_views;
@synthesize nextOrigin = m_nextOrigin;
@synthesize gutter = m_gutter;
@synthesize borderColor = m_borderColor;
@synthesize textColor = m_textColor;
@synthesize backgroundColor = m_backgroundColor;
@synthesize shouldNotShrinkToFit = m_shouldNotShrinkToFit;


- (void)dealloc {
    
    [m_views release];
    [m_borderColor release];
    [m_textColor release];
    [m_backgroundColor release];
    [super dealloc];
}




- (void)clearViews {
    
    if (!self.views) {
        return;
    }
    
    for (UIView *view in self.views) {
        [view removeFromSuperview];
    }
    
    [self.views removeAllObjects];
}



- (void)addView:(UIView *)view {
    
    if (!self.views) {
        NSMutableArray *views = [[NSMutableArray alloc] init];
        self.views = views;
        [views release];
    }
    
    if (self.views.count == 0) {
        self.nextOrigin = CGPointMake(0.0f, 0.0f);
    }
    
    CGRect frame = view.frame;
    frame.origin.x = self.nextOrigin.x;
    frame.origin.y = self.nextOrigin.y;
    view.frame = frame;
    
    if (self.isHorizontal) {
        self.nextOrigin = CGPointMake(self.nextOrigin.x + view.frame.size.width + self.gutter, self.nextOrigin.y);
    }
    else {
        self.nextOrigin = CGPointMake(self.nextOrigin.x, self.nextOrigin.y + view.frame.size.height + self.gutter);
    }
    
    if (self.borderColor) {
        view.layer.borderColor = [self.borderColor CGColor];
        view.layer.borderWidth = 1.0f;
    }
    
    if (self.textColor) {
        if ([view respondsToSelector:@selector(textColor)]) {
            [view setValue:self.textColor forKey:@"textColor"];
        }
    }
    
    if (self.backgroundColor) {
        [view setBackgroundColor:self.backgroundColor];
    }
    
    [self.views addObject:view];
    [self resizeFrame];
    [self addSubview:view];
}


- (void)resizeFrame {
    
    if (self.shouldNotShrinkToFit) {
        return;
    }
    
    
    CGSize maxSize = CGSizeMake(0.0f, 0.0f);
    
    for (UIView *view in self.views) {
        
        CGSize viewSize = view.frame.size;
        
        if (self.isHorizontal) {
            
            maxSize.width += viewSize.width + self.gutter;
            if (maxSize.height < viewSize.height) {
                maxSize.height = viewSize.height;
            }
        }
        else {
            
            maxSize.height += viewSize.height + self.gutter;
            if (maxSize.width < viewSize.width) {
                maxSize.width = viewSize.width;
            }
        }
    }
    
    CGPoint origin = self.frame.origin;
    self.frame = CGRectMake(origin.x, origin.y, maxSize.width, maxSize.height);
}


- (void)setTextColor:(UIColor *)textColor {
    
    if (m_textColor != textColor) {
        [m_textColor release];
        m_textColor = [textColor retain];
    }
    
    for (UIView *view in self.views) {
        if ([view respondsToSelector:@selector(textColor)]) {
            [view setValue:textColor forKey:@"textColor"];
        }
    }
}


- (void)setBackgroundColor:(UIColor *)backgroundColor {
    
    if (m_backgroundColor != backgroundColor) {
        [m_backgroundColor release];
        m_backgroundColor = [backgroundColor retain];
    }
    
    for (UIView *view in self.views) {
        [view setBackgroundColor:backgroundColor];
    }
}




@end
