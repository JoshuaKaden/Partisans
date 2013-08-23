//
//  ScoreViewController.m
//  Partisans
//
//  Created by Joshua Kaden on 8/14/13.
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

#import "ScoreViewController.h"

#import "GameEnvoy.h"
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

- (void)updateLabels;

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
    
    [self updateLabels];
    
    [SystemMessage gameEnvoy].hasScoreBeenShown = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)updateLabels
{
    GameEnvoy *envoy = [SystemMessage gameEnvoy];
    NSUInteger successCount = envoy.successfulMissionCount;
    NSUInteger failCount = envoy.failedMissionCount;
    
    NSString *string = [[NSString alloc] initWithFormat:@"%d", successCount];
    self.scoreLabel1.text = string;
    [string release];
    
    string = [[NSString alloc] initWithFormat:@"%d", failCount];
    self.scoreLabel2.text = string;
    [string release];
    
    
    if (successCount == 1)
    {
        self.titleLabel1.text = NSLocalizedString(@"Successful Mission", @"Successful Mission  --  label");
    }
    else
    {
        self.titleLabel1.text = NSLocalizedString(@"Successful Missions", @"Successful Missions  --  label");
    }
    
    if (failCount == 1)
    {
        self.titleLabel2.text = NSLocalizedString(@"Failed Mission", @"Failed Mission  --  label");
    }
    else
    {
        self.titleLabel2.text = NSLocalizedString(@"Failed Missions", @"Failed Missions  --  label");
    }
    
    
    switch (successCount)
    {
        case 0:
            self.summaryLabel1.text = NSLocalizedString(@"We need to complete three missions to ensure the success of our movement.", @"We need to complete three missions to ensure the success of our movement.  --  summary");
            break;
            
        case 1:
            self.summaryLabel1.text = NSLocalizedString(@"If we can manage to complete two more missions, then we will have won.", @"If we can manage to complete two more missions, then we will have won.  --  summary");
            break;
            
        case 2:
            self.summaryLabel1.text = NSLocalizedString(@"We are only one successful mission away from victory!", @"We are only one successful mission away from victory!  --  summary");
            break;
        
        case 3:
            self.summaryLabel1.text = NSLocalizedString(@"We have triumphed!", @"We have triumphed!  --  summary");
            break;
            
        default:
            break;
    }
    
    switch (failCount)
    {
        case 0:
            self.summaryLabel2.text = NSLocalizedString(@"The Operatives will need to sabotage three missions to prevent our success.", @"The Operatives will need to sabotage three missions to prevent our success.  --  summary");
            break;
            
        case 1:
            self.summaryLabel2.text = NSLocalizedString(@"If the Operatives foil two more missions, then we will have been beaten.", @"If the Operatives foil two more missions, then we will have been beaten.  --  summary");
            break;
            
        case 2:
            self.summaryLabel2.text = NSLocalizedString(@"The Operatives need only sabotage one more mission to doom our endeavor!", @"The Operatives need only sabotage one more mission to doom our endeavor!  --  summary");
            break;
            
        case 3:
            self.summaryLabel2.text = NSLocalizedString(@"The Operatives have won!", @"The Operatives have won!  --  summary");
            break;
            
        default:
            break;
    }
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
