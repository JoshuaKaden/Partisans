//
//  MissionViewController.m
//  Partisans
//
//  Created by Joshua Kaden on 7/3/13.
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

#import "MissionViewController.h"

#import "GameEnvoy.h"
#import "HostFinder.h"
#import "MissionEnvoy.h"
#import "PlayerEnvoy.h"
#import "SystemMessage.h"


@interface MissionViewController () <HostFinderDelegate>

@property (nonatomic, strong) IBOutlet UILabel *codenameLabel;
@property (nonatomic, strong) IBOutlet UIButton *performButton;
@property (nonatomic, strong) IBOutlet UILabel *readyLabel;
@property (nonatomic, strong) IBOutlet UISwitch *readySwitch;
@property (nonatomic, strong) IBOutlet UILabel *sabotageLabel;
@property (nonatomic, strong) IBOutlet UISwitch *sabotageSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *privacySwitch;
@property (nonatomic, strong) IBOutlet UILabel *privacyLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) IBOutlet UILabel *statusLabel;

@property (nonatomic, strong) GameEnvoy *gameEnvoy;
@property (nonatomic, strong) MissionEnvoy *missionEnvoy;
@property (nonatomic, strong) NSString *hostPeerID;
@property (nonatomic, assign) BOOL shouldSucceed;
@property (nonatomic, strong) HostFinder *hostFinder;
@property (nonatomic, strong) NSString *responseKey;
@property (nonatomic, assign) BOOL isOperative;

- (IBAction)performButtonPressed:(id)sender;
- (IBAction)readySwitchFlicked:(id)sender;
- (IBAction)sabotageSwitchFlicked:(id)sender;
- (IBAction)privacySwitchFlicked:(id)sender;

- (void)invokeMission;
- (void)performMission:(BOOL)shouldSucceed;
- (void)performMissionLocally:(BOOL)shouldSucceed;
- (void)connectAndPerformMission:(BOOL)shouldSucceed;
- (void)gameChanged:(NSNotification *)notification;
- (BOOL)hasPerformed;


@end


@implementation MissionViewController

@synthesize codenameLabel = m_codenameLabel;
@synthesize performButton = m_performButton;
@synthesize readyLabel = m_readyLabel;
@synthesize readySwitch = m_readySwitch;
@synthesize sabotageLabel = m_sabotageLabel;
@synthesize sabotageSwitch = m_sabotageSwitch;
@synthesize privacyLabel = m_privacyLabel;
@synthesize privacySwitch = m_privacySwitch;
@synthesize gameEnvoy = m_gameEnvoy;
@synthesize missionEnvoy = m_missionEnvoy;
@synthesize hostPeerID = m_hostPeerID;
@synthesize shouldSucceed = m_shouldSucceed;
@synthesize hostFinder = m_hostFinder;
@synthesize responseKey = m_responseKey;
@synthesize isOperative = m_isOperative;
@synthesize statusLabel = m_statusLabel;
@synthesize spinner = m_spinner;


- (void)dealloc
{
    [self.hostFinder setDelegate:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [m_codenameLabel release];
    [m_performButton release];
    [m_readyLabel release];
    [m_readySwitch release];
    [m_sabotageLabel release];
    [m_sabotageSwitch release];
    [m_privacyLabel release];
    [m_privacySwitch release];
    [m_gameEnvoy release];
    [m_missionEnvoy release];
    [m_hostPeerID release];
    [m_hostFinder release];
    [m_responseKey release];
    [m_statusLabel release];
    [m_spinner release];
    
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
    
    self.isOperative = [[SystemMessage gameEnvoy] isPlayerAnOperative:nil];
    
    // Privacy screen.
    [self.performButton setHidden:YES];
    [self.readyLabel setHidden:YES];
    [self.readySwitch setHidden:YES];
    [self.sabotageLabel setHidden:YES];
    [self.sabotageSwitch setHidden:YES];
    
    [self.spinner setHidden:YES];
    [self.statusLabel setText:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Mission


- (BOOL)hasPerformed
{
    PlayerEnvoy *playerEnvoy = [SystemMessage playerEnvoy];
    return [self.missionEnvoy hasPlayerPerformed:playerEnvoy];
}


- (void)invokeMission
{
    [self.performButton setEnabled:NO];
    [self.readySwitch setEnabled:NO];
    [self.sabotageSwitch setEnabled:NO];
    
    BOOL shouldSucceed = !self.sabotageSwitch.isOn;
    if ([SystemMessage isHost])
    {
        [self performMissionLocally:shouldSucceed];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        [self connectAndPerformMission:shouldSucceed];
    }
}


- (void)performMissionLocally:(BOOL)shouldSucceed
{
    PlayerEnvoy *playerEnvoy = [SystemMessage playerEnvoy];
    self.hostPeerID = playerEnvoy.peerID;
    
    // Force a refresh of the locally-referenced objects.
    self.gameEnvoy = nil;
    self.missionEnvoy = nil;
    
    GameEnvoy *gameEnvoy = self.gameEnvoy;
    MissionEnvoy *missionEnvoy = self.missionEnvoy;
    
    if (shouldSucceed)
    {
        [missionEnvoy applyContributeur:playerEnvoy];
    }
    else
    {
        [missionEnvoy applySaboteur:playerEnvoy];
    }
    
    [gameEnvoy commitAndSave];
}


- (void)connectAndPerformMission:(BOOL)shouldSucceed
{
    [self.spinner setHidden:NO];
    [self.spinner startAnimating];
    
    
    if ([SystemMessage isPlayerOnline])
    {
        GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
        self.hostPeerID = gameEnvoy.host.peerID;
        [self performMission:shouldSucceed];
        return;
    }
    
    if (!self.hostFinder)
    {
        HostFinder *hostFinder = [[HostFinder alloc] init];
        [hostFinder setDelegate:self];
        self.hostFinder = hostFinder;
        [hostFinder release];
    }
    NSString *message = NSLocalizedString(@"Connecting...", @"Connecting...  --  message");
    [self.statusLabel setText:message];
    [self.hostFinder connect];
    
    self.shouldSucceed = shouldSucceed;
}


- (void)performMission:(BOOL)shouldSucceed
{
    NSString *status = NSLocalizedString(@"Performing mission...", @"Performing mission...  --  message");
    [self.statusLabel setText:status];
    
    PlayerEnvoy *playerEnvoy = [SystemMessage playerEnvoy];
    
    NSString *hostPeerID = self.hostPeerID;
    self.responseKey = [SystemMessage buildRandomString];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hostAcknowledgement:) name:kPartisansNotificationHostAcknowledgement object:nil];
    
    JSKCommandMessage *message = [[JSKCommandMessage alloc] initWithType:JSKCommandMessageTypeSucceed to:hostPeerID from:playerEnvoy.peerID];
    message.responseKey = self.responseKey;
    if (!shouldSucceed)
    {
        message.commandMessageType = JSKCommandMessageTypeFail;
    }
    [SystemMessage sendCommandMessage:message shouldAwaitResponse:YES];
    [message release];
}


- (void)hostAcknowledgement:(NSNotification *)notification
{
    NSString *responseKey = notification.object;
    if (![responseKey isEqualToString:self.responseKey])
    {
        // Oops! Is this really our notification?
        return;
    }
    
    [self.statusLabel setText:NSLocalizedString(@"Refreshing...", @"Refreshing...  --  message")];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameChanged:) name:kPartisansNotificationGameChanged object:nil];
    [SystemMessage requestGameUpdate];
}

- (void)gameChanged:(NSNotification *)notification
{
    self.gameEnvoy = nil;
    self.missionEnvoy = nil;
    
    if ([self hasPerformed])
    {
        [SystemMessage gameEnvoy].hasScoreBeenShown = YES;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}



#pragma mark - Host Finder delegate

- (void)hostFinder:(HostFinder *)hostFinder isConnectedToHost:(NSString *)hostPeerID
{
    self.hostPeerID = hostPeerID;
    [self performMission:self.shouldSucceed];
}

- (void)hostFinderTimerFired:(HostFinder *)hostFinder
{
    static NSUInteger timeoutCount = 0;
    timeoutCount++;
    if (timeoutCount == 1)
    {
        [self.statusLabel setText:NSLocalizedString(@"Is the Host available?", @"Is the Host available?  --  message")];
    }
    else if (timeoutCount == 2)
    {
        [self.statusLabel setText:NSLocalizedString(@"Trying one last time...", @"Trying one last time...  --  message")];
    }
    else
    {
        [hostFinder stop];
        self.hostFinder = nil;
        timeoutCount = 0;
        
        [self.statusLabel setText:NSLocalizedString(@"Unable to reach the Host.", @"Unable to reach the Host.  --  message")];
        [self.spinner stopAnimating];
        [self.spinner setHidden:YES];
        
        [self.performButton setEnabled:YES];
        [self.readySwitch setEnabled:YES];
        [self.sabotageSwitch setEnabled:YES];
    }
}




#pragma mark - Actions

- (IBAction)performButtonPressed:(id)sender
{
    [self invokeMission];
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

- (IBAction)privacySwitchFlicked:(id)sender
{
    BOOL hidden = self.privacySwitch.isOn;
    [self.performButton setHidden:hidden];
    [self.readySwitch setHidden:hidden];
    [self.readyLabel setHidden:hidden];
    if (self.isOperative)
    {
        [self.sabotageSwitch setHidden:hidden];
        [self.sabotageLabel setHidden:hidden];
    }
}


#pragma mark - Overrides

- (GameEnvoy *)gameEnvoy
{
    if (!m_gameEnvoy)
    {
        self.gameEnvoy = [SystemMessage gameEnvoy];
    }
    return m_gameEnvoy;
}

- (MissionEnvoy *)missionEnvoy
{
    if (!m_missionEnvoy)
    {
        self.missionEnvoy = [self.gameEnvoy currentMission];
    }
    return m_missionEnvoy;
}


@end
