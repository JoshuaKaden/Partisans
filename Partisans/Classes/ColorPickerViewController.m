//
//  ColorPickerViewController.m
//  QuestPlayer
//
//  Created by Joshua Kaden on 4/26/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "ColorPickerViewController.h"
#import "ILColorPickerView.h"

#import <QuartzCore/QuartzCore.h>

@interface ColorPickerViewController () <ILSaturationBrightnessPickerViewDelegate>

@property (nonatomic, strong) IBOutlet UIView *colorChip;
@property (nonatomic, strong) IBOutlet ILSaturationBrightnessPickerView *satBrightPickerView;
@property (nonatomic, strong) IBOutlet ILHuePickerView *huePickerView;
@property (nonatomic, strong) IBOutlet UIButton *saveButton;
@property (nonatomic, strong) IBOutlet UIView *satBrightMatteView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelBarButtonItem;

- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)cancel:(id)sender;

@end

@implementation ColorPickerViewController

@synthesize delegate = m_delegate;
@synthesize color = m_color;
@synthesize colorChip = m_colorChip;
@synthesize satBrightPickerView = m_satBrightPickerView;
@synthesize huePickerView = m_huePickerView;
@synthesize satBrightMatteView = m_satBrightMatteView;
@synthesize cancelBarButtonItem = m_canceBarButtonItem;

- (void)dealloc
{
    [m_color release];
    [m_canceBarButtonItem release];
    [super dealloc];
}

- (id)initWithColor:(UIColor *)color
{
    self = [super init];
    if (self)
    {
        self.color = color;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationItem setRightBarButtonItem:self.cancelBarButtonItem];
    
    [self.colorChip setBackgroundColor:self.color];
    [self.huePickerView setColor:self.color];
    [self.satBrightPickerView setColor:self.color];
    
//    [[self.satBrightMatteView layer] setBorderColor:[UIColor blackColor].CGColor];
//    [[self.satBrightMatteView layer] setBorderWidth:1.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveButtonPressed:(id)sender
{
    self.color = self.colorChip.backgroundColor;
    [self.delegate colorPicked:self.color forPicker:self];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Color Picker delegates

- (void)colorPicked:(UIColor *)newColor forPicker:(ILSaturationBrightnessPickerView *)picker
{
    [self.colorChip setBackgroundColor:newColor];
}

@end
