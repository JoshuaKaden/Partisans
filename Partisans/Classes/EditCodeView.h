//
//  EditCodeView.h
//  Partisans
//
//  Created by Joshua Kaden on 7/28/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EditCodeView;

@protocol EditCodeViewDelegate <NSObject>

- (void)editCodeViewValueDidChange:(EditCodeView *)editView;

@end


@interface EditCodeView : UIView

@property (nonatomic, assign) id <EditCodeViewDelegate> delegate;
@property (nonatomic, assign) NSUInteger code;

- (void)updatePicker;

@end
