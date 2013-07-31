//
//  TestCodeViewController.m
//  Partisans
//
//  Created by Joshua Kaden on 7/29/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "TestCodeViewController.h"
#import "EditCodeView.h"


@interface TestCodeViewController ()

@property (nonatomic, strong) IBOutlet EditCodeView *editCodeView;

@end


@implementation TestCodeViewController

@synthesize editCodeView = m_editCodeView;

- (void)dealloc
{
    [m_editCodeView release];
    [super dealloc];
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
    
    self.title = @"Test Edit Code";
    
    self.editCodeView.code = 1968;
//    self.editCodeView.codeOne = 2;
//    self.editCodeView.codeTwo = 0;
//    self.editCodeView.codeThree = 1;
//    self.editCodeView.codeFour = 3;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.editCodeView updatePicker];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
