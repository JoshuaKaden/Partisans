//
//  DossierViewController.m
//  Partisans
//
//  Created by Joshua Kaden on 7/20/13.
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

#import "DossierViewController.h"

#import "GameEnvoy.h"
#import "JSKViewStack.h"
#import "MissionEnvoy.h"
#import "PlayerEnvoy.h"
#import "SystemMessage.h"


@interface DossierViewController ()

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UIImageView *headshotImageView;
@property (nonatomic, strong) IBOutlet JSKViewStack *serviceRecordViewStack;

@property (nonatomic, strong) UIFont *font;

- (void)addServiceRecordEntry:(NSString *)message;
- (void)generateServiceRecord;

@end


@implementation DossierViewController

@synthesize nameLabel = m_nameLabel;
@synthesize headshotImageView = m_headshotImageView;
@synthesize serviceRecordViewStack = m_serviceRecordViewStack;
@synthesize delegate = m_delegate;
@synthesize font = m_font;


- (void)dealloc
{
    [m_nameLabel release];
    [m_headshotImageView release];
    [m_serviceRecordViewStack release];
    [m_font release];
    
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
    
    self.title = NSLocalizedString(@"Dossier", @"Dossier  --  title");
    
    PlayerEnvoy *playerEnvoy = [self.delegate supplyPlayerEnvoy:self];
    [self.nameLabel setText:playerEnvoy.playerName];
    [self.headshotImageView setImage:playerEnvoy.image];
    
    [self.serviceRecordViewStack setBackgroundColor:[UIColor clearColor]];
    [self.serviceRecordViewStack setShouldNotShrinkToFit:YES];
    
    [self generateServiceRecord];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Private

- (void)generateServiceRecord
{
    GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
    if (!gameEnvoy)
    {
        return;
    }
    
    NSString *playerID = [self.delegate supplyPlayerEnvoy:self].intramuralID;
    
    NSUInteger successfulMissions = 0;
    NSUInteger failedMissions = 0;
    NSUInteger successfulMissionsCoordinated = 0;
    NSUInteger failedMissionsCoordinated = 0;
    
    for (MissionEnvoy *missionEnvoy in gameEnvoy.missionEnvoys)
    {
        BOOL wasOnTeam = NO;
        BOOL wasCoordinater = NO;
        if (missionEnvoy.isComplete)
        {
            for (PlayerEnvoy *teamMember in missionEnvoy.teamMembers)
            {
                if ([teamMember.intramuralID isEqualToString:playerID])
                {
                    // This player was in the mission.
                    wasOnTeam = YES;
                    break;
                }
            }
            if ([missionEnvoy.coordinator.intramuralID isEqualToString:playerID])
            {
                wasCoordinater = YES;
            }
        }
        
        if (wasOnTeam)
        {
            if (missionEnvoy.didSucceed)
            {
                successfulMissions++;
            }
            else
            {
                failedMissions++;
            }
        }
        
        if (wasCoordinater)
        {
            if (missionEnvoy.didSucceed)
            {
                successfulMissionsCoordinated++;
            }
            else
            {
                failedMissionsCoordinated++;
            }
        }
        
    }
    
    if (successfulMissions + failedMissions + successfulMissionsCoordinated + failedMissionsCoordinated == 0)
    {
        return;
    }
    
    NSString *coordinatedPrefix = NSLocalizedString(@"Coordinated", @"Coordinated  --  label prefix");
    NSString *participatedPrefix = NSLocalizedString(@"Participated in", @"Participated in  --  label prefix");
    NSString *successfulSuffix = NSLocalizedString(@"successful missions.", @"successful missions.  --  label suffix");
    NSString *failedSuffix = NSLocalizedString(@"failed missions.", @"failed missions.  --  label suffix");
    NSString *successfulSuffixSingular = NSLocalizedString(@"successful mission.", @"successful mission.  --  label suffix");
    NSString *failedSuffixSingular = NSLocalizedString(@"failed mission.", @"failed mission.  --  label suffix");
    
    if (successfulMissions > 0)
    {
        NSString *spellOut = [SystemMessage spellOutInteger:successfulMissions];
        NSString *suffix = nil;
        if (successfulMissions == 1)
        {
            suffix = successfulSuffixSingular;
        }
        else
        {
            suffix = successfulSuffix;
        }
        NSString *entry = [[NSString alloc] initWithFormat:@"%@ %@ %@", participatedPrefix, spellOut, suffix];
        [self addServiceRecordEntry:entry];
        [entry release];
    }
    
    if (failedMissions > 0)
    {
        NSString *spellOut = [SystemMessage spellOutInteger:failedMissions];
        NSString *suffix = nil;
        if (failedMissions == 1)
        {
            suffix = failedSuffixSingular;
        }
        else
        {
            suffix = failedSuffix;
        }
        NSString *entry = [[NSString alloc] initWithFormat:@"%@ %@ %@", participatedPrefix, spellOut, suffix];
        [self addServiceRecordEntry:entry];
        [entry release];
    }
    
    if (successfulMissionsCoordinated > 0)
    {
        NSString *spellOut = [SystemMessage spellOutInteger:successfulMissionsCoordinated];
        NSString *suffix = nil;
        if (successfulMissionsCoordinated == 1)
        {
            suffix = successfulSuffixSingular;
        }
        else
        {
            suffix = successfulSuffix;
        }
        NSString *entry = [[NSString alloc] initWithFormat:@"%@ %@ %@", coordinatedPrefix, spellOut, suffix];
        [self addServiceRecordEntry:entry];
        [entry release];
    }
    
    if (failedMissionsCoordinated > 0)
    {
        NSString *spellOut = [SystemMessage spellOutInteger:failedMissionsCoordinated];
        NSString *suffix = nil;
        if (failedMissionsCoordinated == 1)
        {
            suffix = failedSuffixSingular;
        }
        else
        {
            suffix = failedSuffix;
        }
        NSString *entry = [[NSString alloc] initWithFormat:@"%@ %@ %@", coordinatedPrefix, spellOut, suffix];
        [self addServiceRecordEntry:entry];
        [entry release];
    }
}


- (void)addServiceRecordEntry:(NSString *)message
{
    CGRect labelFrame = CGRectMake(10.0f, 10.0f, self.serviceRecordViewStack.frame.size.width - 20.0f, 25.0f);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    [label setText:message];
    if (!self.font)
    {
        UIFont *font = [UIFont fontWithName:@"GillSans" size:15];
        self.font = font;
    }
    [label setFont:self.font];
//    [label setFont:[UIFont systemFontOfSize:13.0f]];
    [self.serviceRecordViewStack addView:label];
    [label release];
}



@end
