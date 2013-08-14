//
//  ScoreViewController.m
//  Partisans
//
//  Created by Joshua Kaden on 8/14/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "ScoreViewController.h"

#import "JSKMenuViewController.h"
#import "SetupGameMenuItems.h"
#import "SystemMessage.h"


@interface ScoreViewController ()

@property (nonatomic, strong) IBOutlet UIBarButtonItem *setupButton;
@property (nonatomic, strong) IBOutlet UILabel *scoreLabel1;
@property (nonatomic, strong) IBOutlet UILabel *scoreLabel2;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel1;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel2;
@property (nonatomic, strong) IBOutlet UILabel *summaryLabel1;
@property (nonatomic, strong) IBOutlet UILabel *summaryLabel2;
@property (nonatomic, strong) IBOutlet UIButton *proceedButton;

@property (nonatomic, strong) SetupGameMenuItems *setupMenuItems;

- (IBAction)setupButtonPressed:(id)sender;
- (IBAction)proceedButtonPressed:(id)sender;

@end


@implementation ScoreViewController

@synthesize setupButton = m_setupButton;
@synthesize scoreLabel1 = m_scoreLabel1;
@synthesize scoreLabel2 = m_scoreLabel2;
@synthesize titleLabel1 = m_titleLabel1;
@synthesize titleLabel2 = m_titleLabel2;
@synthesize summaryLabel1 = m_summaryLabel1;
@synthesize summaryLabel2 = m_summaryLabel2;
@synthesize proceedButton = m_proceedButton;
@synthesize setupMenuItems = m_setupMenuItems;


- (void)dealloc
{
    [m_setupButton release];
    [m_scoreLabel1 release];
    [m_scoreLabel2 release];
    [m_titleLabel1 release];
    [m_titleLabel2 release];
    [m_summaryLabel1 release];
    [m_summaryLabel2 release];
    [m_proceedButton release];
    [m_setupMenuItems release];
    
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
    
    self.title = NSLocalizedString(@"Score", @"Score  --  title");
    
    self.setupButton.title = NSLocalizedString(@"Setup", @"Setup  --  title");
    [self.navigationItem setRightBarButtonItem:self.setupButton animated:NO];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (IBAction)setupButtonPressed:(id)sender
{
    if (!self.setupMenuItems)
    {
        SetupGameMenuItems *items = [[SetupGameMenuItems alloc] init];
        self.setupMenuItems = items;
        [items release];
    }
    JSKMenuViewController *vc = [[JSKMenuViewController alloc] init];
    [vc setDelegate:self.setupMenuItems];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}

- (IBAction)proceedButtonPressed:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
