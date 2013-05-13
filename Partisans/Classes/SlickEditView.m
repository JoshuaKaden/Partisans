//
//  SlickEditView.m
//  SeventhTradition
//
//  Created by Joshua Kaden on 2/1/13.
//  Copyright (c) 2013 Sweetheart Software. All rights reserved.
//

#import "SlickEditView.h"


@interface SlickEditView () <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIView *view;
@property (nonatomic, strong) IBOutlet UILabel *echoLabel;
@property (nonatomic, strong) IBOutlet UITextField *textField;

@end



@implementation SlickEditView


@synthesize view = m_view;
@synthesize echoLabel = m_echoLabel;
@synthesize textField = m_textField;
@synthesize textFieldText = m_textFieldText;
@synthesize delegate = m_delegate;
@synthesize placeholder = m_placeholder;



- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [m_view release];
    [m_echoLabel release];
    [m_textField release];
    [m_placeholder release];
    
    [super dealloc];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.echoLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        // Initialization code
        [[NSBundle mainBundle] loadNibNamed:@"SlickEditView" owner:self options:nil];
        CGRect xibViewFrame = frame;
        xibViewFrame.origin.x = 0;
        xibViewFrame.origin.y = 0;
        self.view.frame = xibViewFrame;
        [self addSubview:self.view];
        
        UITextField *textField = self.textField;
        [textField setAdjustsFontSizeToFitWidth:YES];
        [textField setAutocapitalizationType:UITextAutocapitalizationTypeWords];
        [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
        [textField setBackgroundColor:[UIColor whiteColor]];
        [textField setBorderStyle:UITextBorderStyleRoundedRect];
        [textField setClearButtonMode:UITextFieldViewModeAlways];
        [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [textField setDelegate:self];
        [textField setKeyboardType:UIKeyboardTypeAlphabet];
        [textField setSpellCheckingType:UITextSpellCheckingTypeNo];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:self.textField];
    }
    return self;
}


- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [self addSubview:self.view];
}



- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview)
    {
        NSString *text = self.textFieldText;
        [self.textField setText:text];
        self.echoLabel.text = text;
        [self.textField setPlaceholder:self.placeholder];
        
        [self.textField becomeFirstResponder];
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.view.frame;
    frame.size.width = self.frame.size.width;
    frame.size.height = self.frame.size.height;
    self.view.frame = frame;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/







- (void)textDidChange:(NSNotification *)sender {
    
    UITextField *textField = (UITextField *)sender.object;
    
    if (textField == self.textField) {
        [self.echoLabel setText:textField.text];
        self.textFieldText = textField.text;
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    [self.delegate slickEditViewDidFinishEditing:self];
    return NO;
}



@end
