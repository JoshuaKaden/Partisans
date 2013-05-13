//
//  SlickEditView.h
//  SeventhTradition
//
//  Created by Joshua Kaden on 2/1/13.
//  Copyright (c) 2013 Sweetheart Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SlickEditView;


@protocol SlickEditViewProtocol <NSObject>

- (void)slickEditViewDidFinishEditing:(SlickEditView *)slickEditView;

@end


@interface SlickEditView : UIView

@property (nonatomic, strong) NSString *textFieldText;
@property (nonatomic, assign) id <SlickEditViewProtocol> delegate;
@property (nonatomic, strong) NSString *placeholder;

@end
