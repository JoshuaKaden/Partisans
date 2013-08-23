//
//  ColorPickerViewController.m
//  Partisans
//
//  Created by Joshua Kaden on 4/26/13.
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
