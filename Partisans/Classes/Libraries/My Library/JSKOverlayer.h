//
//  JSKOverlayer.h
//
//  Created by Joshua Kaden on 6/28/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JSKOverlayer : NSObject

@property (assign, nonatomic) UIView *view;

- (id)initWithView:(UIView *)view;
- (void)removeWaitOverlay;
- (void)createWaitOverlayWithText:(NSString *)text;
- (void)updateWaitOverlayText:(NSString *)text;

@end
