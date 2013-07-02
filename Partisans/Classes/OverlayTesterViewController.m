//
//  OverlayTesterViewController.m
//  Partisans
//
//  Created by Joshua Kaden on 7/2/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "OverlayTesterViewController.h"

#import "JSKOverlayer.h"
#import "SystemMessage.h"


@interface OverlayTesterViewController ()

@property (nonatomic, strong) JSKOverlayer *overlayer;

- (IBAction)buttonWasPressed:(id)sender;

@end


@implementation OverlayTesterViewController

@synthesize overlayer = m_overlayer;

- (void)dealloc
{
    [m_overlayer release];
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
	// Do any additional setup after loading the view.
    self.title = @"Overlay Tester";
    
    JSKOverlayer *overlayer = [[JSKOverlayer alloc] initWithView:[SystemMessage rootView]];
    self.overlayer = overlayer;
    [overlayer release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonWasPressed:(id)sender
{
    [self.overlayer createWaitOverlayWithText:@"Testing...."];
}

@end
