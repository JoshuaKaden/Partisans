//
//  EditCodeView.m
//  Partisans
//
//  Created by Joshua Kaden on 7/28/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "EditCodeView.h"


@interface EditCodeView () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) IBOutlet UIView *view;
@property (nonatomic, strong) IBOutlet UILabel *labelOne;
@property (nonatomic, strong) IBOutlet UILabel *labelTwo;
@property (nonatomic, strong) IBOutlet UILabel *labelThree;
@property (nonatomic, strong) IBOutlet UILabel *labelFour;
@property (nonatomic, strong) IBOutlet UIPickerView *picker;

@property (nonatomic, assign) NSUInteger codeOne;
@property (nonatomic, assign) NSUInteger codeTwo;
@property (nonatomic, assign) NSUInteger codeThree;
@property (nonatomic, assign) NSUInteger codeFour;

@end


@implementation EditCodeView

@synthesize code = m_code;
@synthesize view = m_view;
@synthesize labelOne = m_labelOne;
@synthesize labelTwo = m_labelTwo;
@synthesize labelThree = m_labelThree;
@synthesize labelFour = m_labelFour;
@synthesize picker = m_picker;
@synthesize delegate = m_delegate;


- (void)dealloc
{
    [self.picker setDataSource:nil];
    [self.picker setDelegate:nil];
    
    [m_view release];
    [m_labelOne release];
    [m_labelTwo release];
    [m_labelThree release];
    [m_labelFour release];
    [m_picker release];
    
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


- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [self addSubview:self.view];
}



- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview)
    {
        [self updatePicker];
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



- (void)updatePicker
{
    NSString *labelText = [[NSString alloc] initWithFormat:@"%d", self.codeOne];
    [self.labelOne setText:labelText];
    [labelText release];
    
    labelText = [[NSString alloc] initWithFormat:@"%d", self.codeTwo];
    [self.labelTwo setText:labelText];
    [labelText release];
    
    labelText = [[NSString alloc] initWithFormat:@"%d", self.codeThree];
    [self.labelThree setText:labelText];
    [labelText release];
    
    labelText = [[NSString alloc] initWithFormat:@"%d", self.codeFour];
    [self.labelFour setText:labelText];
    [labelText release];
    
    [self.picker selectRow:self.codeOne - 1 inComponent:0 animated:YES];
    [self.picker selectRow:self.codeTwo inComponent:1 animated:YES];
    [self.picker selectRow:self.codeThree inComponent:2 animated:YES];
    [self.picker selectRow:self.codeFour inComponent:3 animated:YES];
}



#pragma mark - Code digitizing

- (void)setCode:(NSUInteger)code
{
    if (code < 1000)
    {
        code = 1000;
    }
    
    m_code = code;
    
    NSNumber *codeNumber = [[NSNumber alloc] initWithUnsignedInteger:code];
    NSString *gameCodeString = codeNumber.description;
    [codeNumber release];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterNoStyle];
    NSUInteger gameCodeDigit = [[formatter numberFromString:[gameCodeString substringWithRange:NSMakeRange(0, 1)]] unsignedIntegerValue];
    [self setCodeOne:gameCodeDigit];
    gameCodeDigit = [[formatter numberFromString:[gameCodeString substringWithRange:NSMakeRange(1, 1)]] unsignedIntegerValue];
    [self setCodeTwo:gameCodeDigit];
    gameCodeDigit = [[formatter numberFromString:[gameCodeString substringWithRange:NSMakeRange(2, 1)]] unsignedIntegerValue];
    [self setCodeThree:gameCodeDigit];
    gameCodeDigit = [[formatter numberFromString:[gameCodeString substringWithRange:NSMakeRange(3, 1)]] unsignedIntegerValue];
    [self setCodeFour:gameCodeDigit];
    [formatter release];
}


#pragma mark - UIPicker datasource and delegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 4;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0)
    {
        return 9;
    }
    else
    {
        return 10;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *returnValue = nil;
    NSUInteger digit = row + 1;
    if (component > 0)
    {
        digit = row;
    }
    NSNumber *number = [[NSNumber alloc] initWithUnsignedInteger:digit];
    returnValue = [NSString stringWithFormat:@"%@", number.description];
    [number release];
    return returnValue;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSUInteger digit = row + 1;
    if (component > 0)
    {
        digit = row;
    }
    NSNumber *number = [[NSNumber alloc] initWithInteger:digit];
    switch (component)
    {
        case 0:
            self.codeOne = digit;
            [self.labelOne setText:number.description];
            break;
            
        case 1:
            self.codeTwo = digit;
            [self.labelTwo setText:number.description];
            break;
            
        case 2:
            self.codeThree = digit;
            [self.labelThree setText:number.description];
            break;
            
        case 3:
            self.codeFour = digit;
            [self.labelFour setText:number.description];
            break;
            
        default:
            break;
    }
    [number release];
    
    m_code = (self.codeOne * 1000) + (self.codeTwo * 100) + (self.codeThree * 10) + self.codeFour;
    
    [self.delegate editCodeViewValueDidChange:self];
}

@end
