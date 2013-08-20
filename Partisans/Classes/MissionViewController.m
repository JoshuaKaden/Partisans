//
//  MissionViewController.m
//  Partisans
//
//  Created by Joshua Kaden on 7/3/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "MissionViewController.h"

#import "GameEnvoy.h"
#import "HostFinder.h"
#import "MissionEnvoy.h"
#import "JSKOverlayer.h"
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

@property (nonatomic, strong) GameEnvoy *gameEnvoy;
@property (nonatomic, strong) MissionEnvoy *missionEnvoy;
@property (nonatomic, strong) NSString *hostPeerID;
@property (nonatomic, assign) BOOL shouldSucceed;
@property (nonatomic, strong) JSKOverlayer *overlayer;
@property (nonatomic, strong) HostFinder *hostFinder;
@property (nonatomic, strong) NSString *responseKey;
@property (nonatomic, assign) BOOL hasActionBeenConfirmed;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL isOperative;

- (IBAction)performButtonPressed:(id)sender;
- (IBAction)readySwitchFlicked:(id)sender;
- (IBAction)sabotageSwitchFlicked:(id)sender;
- (IBAction)privacySwitchFlicked:(id)sender;

- (void)performMission:(BOOL)shouldSucceed;
- (void)performMissionLocally:(BOOL)shouldSucceed;
- (void)connectAndPerformMission:(BOOL)shouldSucceed;
- (void)gameChanged:(NSNotification *)notification;
- (void)timerFired:(id)sender;

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
@synthesize overlayer = m_overlayer;
@synthesize hostFinder = m_hostFinder;
@synthesize responseKey = m_responseKey;
@synthesize hasActionBeenConfirmed = m_hasActionBeenConfirmed;
@synthesize timer = m_timer;
@synthesize isOperative = m_isOperative;


- (void)dealloc
{
    [self.hostFinder setDelegate:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.timer invalidate];
    
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
    [m_overlayer release];
    [m_hostFinder release];
    [m_responseKey release];
    [m_timer release];
    
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
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)timerFired:(id)sender
{
    static NSUInteger timeoutCount = 0;
    timeoutCount++;
    if (timeoutCount == 1)
    {
        [self.overlayer updateWaitOverlayText:NSLocalizedString(@"Is the Host available?", @"Is the Host available?  --  message")];
    }
    else if (timeoutCount == 2)
    {
        [self.overlayer updateWaitOverlayText:NSLocalizedString(@"Trying one last time...", @"Trying one last time...  --  message")];
    }
    else
    {
        [self.timer invalidate];
        self.timer = nil;
        [self.overlayer removeWaitOverlay];
        timeoutCount = 0;
        [self.performButton setEnabled:YES];
        [self.readySwitch setEnabled:YES];
        [self.sabotageSwitch setEnabled:YES];
    }
}


#pragma mark - Mission


- (void)performMissionLocally:(BOOL)shouldSucceed
{
    PlayerEnvoy *playerEnvoy = [SystemMessage playerEnvoy];
    self.hostPeerID = playerEnvoy.peerID;
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
    
//    if (![SystemMessage isPlayerOnline])
//    {
//        [SystemMessage putPlayerOnline];
//    }
//    JSKCommandParcel *parcel = [[JSKCommandParcel alloc] initWithType:JSKCommandParcelTypeUpdate to:nil from:self.hostPeerID object:[NSArray arrayWithObject:missionEnvoy]];
//    [SystemMessage sendParcelToPlayers:parcel];
//    [parcel release];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (void)connectAndPerformMission:(BOOL)shouldSucceed
{
    [self.performButton setEnabled:NO];
    [self.readySwitch setEnabled:NO];
    [self.sabotageSwitch setEnabled:NO];
    
    if (!self.overlayer)
    {
        JSKOverlayer *overlayer = [[JSKOverlayer alloc] initWithView:[SystemMessage rootView]];
        self.overlayer = overlayer;
        [overlayer release];
    }
    NSString *message = NSLocalizedString(@"Performing mission...", @"Performing mission...  --  message");
    [self.overlayer createWaitOverlayWithText:message];
    
    
    if ([SystemMessage isPlayerOnline])
    {
        self.hostPeerID = self.gameEnvoy.host.peerID;
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
    [self.hostFinder connect];
    
    self.shouldSucceed = shouldSucceed;
    
    if (!self.timer)
    {
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
        self.timer = timer;
    }
}


- (void)performMission:(BOOL)shouldSucceed
{
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
    
    self.hasActionBeenConfirmed = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameChanged:) name:kPartisansNotificationGameChanged object:nil];
    [SystemMessage requestGameUpdate];
}

- (void)gameChanged:(NSNotification *)notification
{
    if (self.hasActionBeenConfirmed)
    {
        [self.overlayer removeWaitOverlay];
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
        [self.overlayer updateWaitOverlayText:NSLocalizedString(@"Is the Host available?", @"Is the Host available?  --  message")];
    }
    else if (timeoutCount == 2)
    {
        [self.overlayer updateWaitOverlayText:NSLocalizedString(@"Trying one last time...", @"Trying one last time...  --  message")];
    }
    else
    {
        [hostFinder stop];
        self.hostFinder = nil;
        [self.overlayer removeWaitOverlay];
    }
}




#pragma mark - Actions

- (IBAction)performButtonPressed:(id)sender
{
    BOOL shouldSucceed = YES;
    if (self.sabotageSwitch.isOn)
    {
        shouldSucceed = NO;
    }
    if ([SystemMessage isHost])
    {
        [self performMissionLocally:shouldSucceed];
    }
    else
    {
        [self connectAndPerformMission:shouldSucceed];
    }
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
