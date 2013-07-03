//
//  MissionViewController.m
//  Partisans
//
//  Created by Joshua Kaden on 7/3/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "MissionViewController.h"

#import "GameEnvoy.h"
#import "MissionEnvoy.h"
#import "SystemMessage.h"


@interface MissionViewController ()

@property (nonatomic, strong) IBOutlet UILabel *codenameLabel;
@property (nonatomic, strong) IBOutlet UIButton *performButton;
@property (nonatomic, strong) IBOutlet UILabel *readyLabel;
@property (nonatomic, strong) IBOutlet UISwitch *readySwitch;
@property (nonatomic, strong) IBOutlet UILabel *sabotageLabel;
@property (nonatomic, strong) IBOutlet UISwitch *sabotageSwitch;

@property (nonatomic, strong) MissionEnvoy *missionEnvoy;

- (IBAction)performButtonPressed:(id)sender;
- (IBAction)readySwitchFlicked:(id)sender;
- (IBAction)sabotageSwitchFlicked:(id)sender;

- (void)performMission:(BOOL)shouldSucceed;

@end


@implementation MissionViewController

@synthesize codenameLabel = m_codenameLabel;
@synthesize performButton = m_performButton;
@synthesize readyLabel = m_readyLabel;
@synthesize readySwitch = m_readySwitch;
@synthesize sabotageLabel = m_sabotageLabel;
@synthesize sabotageSwitch = m_sabotageSwitch;
@synthesize missionEnvoy = m_missionEnvoy;


- (void)dealloc
{
    [m_codenameLabel release];
    [m_performButton release];
    [m_readyLabel release];
    [m_readySwitch release];
    [m_sabotageLabel release];
    [m_sabotageSwitch release];
    [m_missionEnvoy release];
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
    
    // The title.
    NSString *titlePrefix = NSLocalizedString(@"Mission", @"Mission  --  prefix");
    NSString *spelledNumber = [SystemMessage spellOutNumber:[NSNumber numberWithUnsignedInteger:self.missionEnvoy.missionNumber]];
    NSString *title = [NSString stringWithFormat:@"%@ %@", titlePrefix, [spelledNumber capitalizedString]];
    self.title = title;
    
    // The codename.
    NSString *codenamePrefix = NSLocalizedString(@"Codename", @"Codename  --  label prefix");
    self.codenameLabel.text = [NSString stringWithFormat:@"%@: %@", codenamePrefix, self.missionEnvoy.missionName];
    
    BOOL preventSabotage = ![[SystemMessage gameEnvoy] isPlayerAnOperative:nil];
    self.sabotageLabel.hidden = preventSabotage;
    self.sabotageSwitch.hidden = preventSabotage;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Mission

- (void)performMission:(BOOL)shouldSucceed
{
    debugLog(@"boom");
}



#pragma mark - Actions

- (IBAction)performButtonPressed:(id)sender
{
    BOOL shouldSucceed = YES;
    if (self.sabotageSwitch.isOn)
    {
        shouldSucceed = NO;
    }
    [self performMission:shouldSucceed];
}

- (IBAction)readySwitchFlicked:(id)sender
{
    self.performButton.enabled = self.readySwitch.isOn;
}

- (IBAction)sabotageSwitchFlicked:(id)sender
{
    [self.readySwitch setOn:self.sabotageSwitch.isOn animated:YES];
    self.performButton.enabled = self.readySwitch.isOn;
}


#pragma mark - Overrides

- (MissionEnvoy *)missionEnvoy
{
    if (!m_missionEnvoy)
    {
        self.missionEnvoy = [[SystemMessage gameEnvoy] currentMission];
    }
    return m_missionEnvoy;
}


@end
