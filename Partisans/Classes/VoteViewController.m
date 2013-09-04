//
//  VoteViewController.m
//  Partisans
//
//  Created by Joshua Kaden on 7/18/13.
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

#import "VoteViewController.h"

#import "CoordinatorVote.h"
#import "GameEnvoy.h"
#import "HostFinder.h"
#import "JSKCommandParcel.h"
#import "PlayerEnvoy.h"
#import "RoundEnvoy.h"
#import "SystemMessage.h"
#import "VoteEnvoy.h"


@interface VoteViewController () <HostFinderDelegate>

@property (nonatomic, strong) IBOutlet UISwitch *yeaSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *naySwitch;
@property (nonatomic, strong) IBOutlet UILabel *yeaLabel;
@property (nonatomic, strong) IBOutlet UILabel *nayLabel;
@property (nonatomic, strong) IBOutlet UIButton *voteButton;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) IBOutlet UIButton *proceedButton;

@property (nonatomic, strong) HostFinder *hostFinder;
@property (nonatomic, strong) NSString *hostPeerID;
@property (nonatomic, assign) BOOL thisVote;
@property (nonatomic, strong) NSString *responseKey;

- (IBAction)yeaSwitchFlicked:(id)sender;
- (IBAction)naySwitchFlicked:(id)sender;
- (IBAction)voteButtonPressed:(id)sender;
- (IBAction)proceedButtonPressed:(id)sender;

- (void)doneButtonPressed:(id)sender;
- (void)invokeVote;

@end


@implementation VoteViewController

@synthesize yeaSwitch = m_yeaSwitch;
@synthesize naySwitch = m_naySwitch;
@synthesize yeaLabel = m_yeaLabel;
@synthesize nayLabel = m_nayLabel;
@synthesize voteButton = m_voteButton;
@synthesize spinner = m_spinner;
@synthesize statusLabel = m_statusLabel;
@synthesize hostFinder = m_hostFinder;
@synthesize hostPeerID = m_hostPeerID;
@synthesize thisVote = m_thisVote;
@synthesize responseKey = m_responseKey;
@synthesize proceedButton = m_proceedButton;


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.hostFinder setDelegate:nil];
    
    [m_yeaSwitch release];
    [m_naySwitch release];
    [m_yeaLabel release];
    [m_nayLabel release];
    [m_voteButton release];
    [m_spinner release];
    [m_statusLabel release];
    [m_hostFinder release];
    [m_hostPeerID release];
    [m_responseKey release];
    [m_proceedButton release];
    
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
    
    self.title = NSLocalizedString(@"Voting Booth", @"Voting Booth  --  title");
    
    [self.yeaLabel setText:NSLocalizedString(@"Vote YEA", @"Vote YEA  --  label")];
    [self.nayLabel setText:NSLocalizedString(@"Vote NAY", @"Vote NAY  --  label")];
    [self.voteButton.titleLabel setText:NSLocalizedString(@"Vote", @"Vote  --  label")];
    [self.proceedButton.titleLabel setText:NSLocalizedString(@"Proceed", @"Proceed  --  label")];
    
    [self.yeaSwitch setOn:NO animated:NO];
    [self.naySwitch setOn:NO animated:NO];
    [self.voteButton setEnabled:NO];
    [self.spinner setHidden:YES];
    [self.statusLabel setText:nil];
    [self.proceedButton setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (IBAction)yeaSwitchFlicked:(id)sender
{
    if (self.yeaSwitch.isOn)
    {
        [self.naySwitch setOn:NO animated:YES];
        [self.voteButton setEnabled:YES];
    }
    else
    {
        if (!self.naySwitch.isOn)
        {
            [self.voteButton setEnabled:NO];
        }
    }
}

- (IBAction)naySwitchFlicked:(id)sender
{
    if (self.naySwitch.isOn)
    {
        [self.yeaSwitch setOn:NO animated:YES];
        [self.voteButton setEnabled:YES];
    }
    else
    {
        if (!self.yeaSwitch.isOn)
        {
            [self.voteButton setEnabled:NO];
        }
    }
}

- (IBAction)voteButtonPressed:(id)sender
{
    [self invokeVote];
}


- (void)doneButtonPressed:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)proceedButtonPressed:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}



#pragma mark - Voting


- (BOOL)hasVoted
{
    return [[[SystemMessage gameEnvoy] currentRound] hasPlayerVoted:nil];
//BOOL returnValue = NO;
//    PlayerEnvoy *playerEnvoy = [SystemMessage playerEnvoy];
//    RoundEnvoy *currentRound = [[SystemMessage gameEnvoy] currentRound];
//    for (VoteEnvoy *voteEnvoy in currentRound.votes)
//    {
//        if ([voteEnvoy.playerID isEqualToString:playerEnvoy.intramuralID])
//        {
//            returnValue = YES;
//            break;
//        }
//    }
//    return returnValue;
}


- (void)invokeVote
{
    [self.yeaSwitch setEnabled:NO];
    [self.naySwitch setEnabled:NO];
    [self.yeaLabel setEnabled:NO];
    [self.nayLabel setEnabled:NO];
    [self.voteButton setEnabled:NO];
    
    if ([self hasVoted])
    {
        [self.statusLabel setText:NSLocalizedString(@"Already voted!", @"Already voted!  --  label")];
        return;
    }
    
    BOOL vote = self.yeaSwitch.isOn;
    if ([SystemMessage isHost])
    {
        [self voteLocally:vote];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        [self connectAndVote:vote];
    }
}


- (void)voteLocally:(BOOL)vote
{
    self.hostPeerID = [SystemMessage playerEnvoy].peerID;
    GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
    RoundEnvoy *currentRound = [gameEnvoy currentRound];
    
    VoteEnvoy *voteEnvoy = [[VoteEnvoy alloc] init];
    voteEnvoy.isCast = YES;
    voteEnvoy.isYea = vote;
    voteEnvoy.roundID = currentRound.intramuralID;
    voteEnvoy.playerID = [SystemMessage playerEnvoy].intramuralID;
    [currentRound addVote:voteEnvoy];
    [voteEnvoy release];
    
    [gameEnvoy commitAndSave];
}


- (void)connectAndVote:(BOOL)vote
{
    [self.spinner setHidden:NO];
    [self.spinner startAnimating];
    
    
    if ([SystemMessage isPlayerOnline])
    {
        GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
        self.hostPeerID = gameEnvoy.host.peerID;
        [self vote:vote];
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
    
    self.thisVote = vote;
}


- (void)vote:(BOOL)vote
{
    NSString *message = NSLocalizedString(@"Voting...", @"Voting...  --  message");
    [self.statusLabel setText:message];
    
    PlayerEnvoy *playerEnvoy = [SystemMessage playerEnvoy];
    RoundEnvoy *currentRound = [[SystemMessage gameEnvoy] currentRound];
    BOOL isCoordinator = NO;
    if ([currentRound.coordinatorID isEqualToString:playerEnvoy.intramuralID])
    {
        isCoordinator = YES;
    }
    
    // This involves sending a new (unconnected to core data) vote envoy to the host.
    // After the vote is acknowledged by the host, go to the results screen.
    // The host will update the game, and broadcast an update.
    
    NSObject <NSCoding> *parcelObject = nil;
    
    VoteEnvoy *voteEnvoy = [[VoteEnvoy alloc] init];
    voteEnvoy.isCast = NO;
    voteEnvoy.isYea = vote;
    voteEnvoy.roundID = currentRound.intramuralID;
    voteEnvoy.playerID = playerEnvoy.intramuralID;
    
    if (isCoordinator)
    {
        // The Coordinator has to send the team candidates to the host, along with the vote.
        CoordinatorVote *coordinatorVote = [[CoordinatorVote alloc] init];
        coordinatorVote.voteEnvoy = voteEnvoy;
        coordinatorVote.candidateIDs = [currentRound.candidates valueForKey:@"intramuralID"];
        parcelObject = [coordinatorVote retain];
        [coordinatorVote release];
    }
    else
    {
        parcelObject = [voteEnvoy retain];
    }
    
    [voteEnvoy release];
    
    
    NSString *hostPeerID = self.hostPeerID;
    self.responseKey = [SystemMessage buildRandomString];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hostAcknowledgement:) name:kPartisansNotificationHostAcknowledgement object:nil];
    
    JSKCommandParcel *parcel = [[JSKCommandParcel alloc] initWithType:JSKCommandParcelTypeUpdate to:hostPeerID from:playerEnvoy.peerID object:parcelObject responseKey:self.responseKey];
    [parcelObject release];
    [SystemMessage sendCommandParcel:parcel shouldAwaitResponse:YES];
    [parcel release];
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
    if ([self hasVoted])
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        [self.statusLabel setText:NSLocalizedString(@"Your vote has been submitted.", @"Your vote has been submitted.  --  message")];
        [self.spinner stopAnimating];
        [self.spinner setHidden:YES];
        
//        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
//        [self.navigationItem setRightBarButtonItem:doneButton animated:YES];
//        [doneButton release];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
//        [self.proceedButton setHidden:NO];
    }
}



#pragma mark - Host Finder delegate

- (void)hostFinder:(HostFinder *)hostFinder isConnectedToHost:(NSString *)hostPeerID
{
    [self.hostFinder stop];
    self.hostPeerID = hostPeerID;
    [self vote:self.thisVote];
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
        
        [self.yeaSwitch setEnabled:YES];
        [self.naySwitch setEnabled:YES];
        [self.yeaLabel setEnabled:YES];
        [self.nayLabel setEnabled:YES];
        [self.voteButton setEnabled:YES];
    }
}



@end
