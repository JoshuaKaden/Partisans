//
//  JoinGameViewController.m
//  Partisans
//
//  Created by Joshua Kaden on 5/17/13.
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

#import "JoinGameViewController.h"

#import "GameCodeViewController.h"
#import "GameJoiner.h"
#import "JSKMenuViewController.h"
#import "JSKViewStack.h"
#import "SetupGameMenuItems.h"
#import "SystemMessage.h"


@interface JoinGameViewController () <GameJoinerDelegate, UIAlertViewDelegate, GameCodeViewControllerDelegate>

@property (nonatomic, strong) JSKViewStack *viewStack;
@property (nonatomic, assign) BOOL isScanning;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, assign) BOOL isFinished;
@property (nonatomic, strong) GameJoiner *gameJoiner;
@property (nonatomic, assign) NSUInteger gameCode;

- (void)addStatusMessage:(NSString *)message;
- (void)startScanning;
- (void)stopScanning;
- (void)toggleColors;
- (void)handleTap:(UITapGestureRecognizer *)recognizer;
- (UIColor *)screenBackgroundColor;
- (UIColor *)screenTextColor;
- (void)clearStatusMessages;

@end


@implementation JoinGameViewController

@synthesize viewStack = m_viewStack;
@synthesize isScanning = m_isScanning;
@synthesize tapGesture = m_tapGesture;
@synthesize isFinished = m_isFinished;
@synthesize gameJoiner = m_gameJoiner;
@synthesize gameCode = m_gameCode;


#pragma mark - Boilerplate

- (void)dealloc
{
    [m_gameJoiner setDelegate:nil];
    
    
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
    
    self.title = NSLocalizedString(@"Game Scanner", @"Game Scanner  --  title for view controller");
    
    UIColor *backgroundColor = [UIColor blackColor];
    [self.view setBackgroundColor:backgroundColor];
    
    
    CGRect stackFrame = CGRectMake(10.0f, 10.0f, 0.0f, 0.0f);
    JSKViewStack *viewStack = [[JSKViewStack alloc] initWithFrame:stackFrame];
    
    [viewStack setBackgroundColor:backgroundColor];
    [viewStack setTextColor:[UIColor whiteColor]];
    
    self.viewStack = viewStack;
    
    [self.view addSubview:viewStack];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    self.tapGesture = tapGesture;
    
    [self.view addGestureRecognizer:self.tapGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self clearStatusMessages];
    
    if (self.gameCode == 0)
    {
        NSString *message = NSLocalizedString(@"The Host has the Game Code.", @"The Host has the Game Code.  --  status message");
        [self addStatusMessage:message];
        message = NSLocalizedString(@"Tap to enter the Code.", @"Tap to enter the Code.  --  status message");
        [self addStatusMessage:message];
        return;
    }
    
    NSString *prefix = NSLocalizedString(@"The Game Code is", @"The Game Code is  --  prefix");
    NSString *message = [NSString stringWithFormat:@"%@ %d.", prefix, self.gameCode];
    [self addStatusMessage:message];
    
    message = NSLocalizedString(@"Tap to start scanning.", @"Tap to start scanning.  --  status message");
    [self addStatusMessage:message];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.viewStack = nil;
    [self.view removeGestureRecognizer:self.tapGesture];
    self.tapGesture = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


#pragma mark - Private

- (void)handleTap:(UITapGestureRecognizer *)recognizer
{
    if (self.isFinished)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    
    if (self.gameCode == 0)
    {
        GameCodeViewController *vc = [[GameCodeViewController alloc] init];
        [vc setDelegate:self];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    if (self.isScanning)
    {
        [self stopScanning];
        return;
    }
    
    [self startScanning];
    
    //    CGPoint location = [recognizer locationInView:[recognizer.view superview]];
}



- (void)addStatusMessage:(NSString *)message {
    
    CGRect labelFrame = CGRectMake(10.0f, 10.0f, self.view.frame.size.width - 20.0f, 35.0f);
    UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
    
    [label setText:message];
    
    [self.viewStack addView:label];
}

- (void)clearStatusMessages
{
    [self.viewStack clearViews];
}


- (void)startScanning {
    
    if (self.isScanning) {
        return;
    }
    
    self.isScanning = YES;
    
    [self toggleColors];
    
    [self.viewStack clearViews];
    
    NSString *prefix = NSLocalizedString(@"The Game Code is", @"The Game Code is  --  prefix");
    NSString *message = [NSString stringWithFormat:@"%@ %d.", prefix, self.gameCode];
    [self addStatusMessage:message];
    
    if (!self.gameJoiner)
    {
        GameJoiner *gameJoiner = [[GameJoiner alloc] init];
        [gameJoiner setDelegate:self];
        gameJoiner.gameCode = self.gameCode;
        self.gameJoiner = gameJoiner;
    }
    
    [self.gameJoiner startScanning];
}



- (void)stopScanning {
    
    if (!self.isScanning) {
        return;
    }
    
    self.isScanning = NO;
    
    [self toggleColors];
    
    [self.gameJoiner stopScanning];
}


- (void)toggleColors {
    
    UIColor *backgroundColor = nil;
    UIColor *textColor = nil;
    
    if (self.isScanning) {
        backgroundColor = [self screenBackgroundColor];
        textColor = [self screenTextColor];
    }
    else {
        backgroundColor = [UIColor blackColor];
        textColor = [UIColor whiteColor];
    }
    
    [self.view setBackgroundColor:backgroundColor];
    [self.viewStack setBackgroundColor:backgroundColor];
    [self.viewStack setTextColor:(UIColor *)textColor];
}


- (UIColor *)screenBackgroundColor {
    
    UIColor *color = [UIColor colorWithRed:43.0f/255.0f green:144.0f/255.0f blue:206.0f/255.0f alpha:1.0f];
    return color;
}

- (UIColor *)screenTextColor {
    
    UIColor *color = [UIColor blackColor];
    return color;
}



#pragma mark - GameJoiner delegate

- (void)gameJoiner:(GameJoiner *)gameJoiner handleStatusMessage:(NSString *)message
{
    [self performSelectorOnMainThread:@selector(addStatusMessage:) withObject:message waitUntilDone:NO];
}

- (void)gameJoinerDidFinish:(GameJoiner *)gameJoiner
{
    [self stopScanning];
    [self.navigationController popToRootViewControllerAnimated:NO];
    
//    JSKMenuViewController *vc = [[JSKMenuViewController alloc] init];
//    SetupGameMenuItems *items = [[SetupGameMenuItems alloc] init];
//    [vc setDelegate:items];
//    [items release];
//    
//    [self.navigationController popViewControllerAnimated:NO];
//    [self.navigationController pushViewController:vc animated:YES];
//    [vc release];
}

//#pragma mark - PeerImporterDelegate
//
//
//- (void)peerImporter:(PeerImporter *)peerImporter handleStatusMessage:(NSString *)message {
//    
//    [self performSelectorOnMainThread:@selector(addStatusMessage:) withObject:message waitUntilDone:NO];
//}
//
//
//- (void)peerImporter:(PeerImporter *)peerImporter hasAvailableExporter:(NSString *)exporterName peerInfoMessage:(PeerInfoMessage *)peerInfoMessage {
//    
//    // Bail if we're already importing.
//    if (self.isImporting) {
//        return;
//    }
//    
//    self.isImporting = YES;
//    
//    self.exporterInfo = peerInfoMessage;
//    
//    NSString *title = NSLocalizedString(@"Confirmation", @"Confirmation  -  title for alert view");
//    
//    NSString *start = NSLocalizedString(@"Would you like to import the meeting named:", @"Would you like to import the meeting\nnamed:  -  start of message for alert view");
//    NSString *fromPrefix = NSLocalizedString(@"from:", @"from:  -  prefix for alert view message");
//    NSString *end = NSLocalizedString(@"?", @"?  -  closing question-mark");
//    
//    NSString *message = [NSString stringWithFormat:@"%@ %@\n%@ %@%@", start, self.exporterInfo.meetingEnvoy.name, fromPrefix, exporterName, end];
//    
//    //    NSString *start = NSLocalizedString(@"Would you like to import the meeting named:", @"Would you like to import the meeting\nnamed:  -  start of message for alert view");
//    //    NSString *balancePrefix = NSLocalizedString(@"treasury balance:", @"treasury balance:  -  prefix for alert view message");
//    //    NSString *fromPrefix = NSLocalizedString(@"from:", @"from:  -  prefix for alert view message");
//    //    NSString *end = NSLocalizedString(@"?", @"?  -  closing question-mark");
//    //
//    //    NSDecimal balanceDecimal = self.exporterInfo.meetingMetricsEnvoy.beginningBalance;
//    //    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//    //    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
//    //    NSString *balance = [formatter stringFromNumber:[NSDecimalNumber decimalNumberWithDecimal:balanceDecimal]];
//    //    [formatter release];
//    //
//    //    NSString *message = [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@ %@%@", start, self.exporterInfo.meetingEnvoy.name, balancePrefix, balance, fromPrefix, exporterName, end];
//    
//    NSString *cancelTitle = NSLocalizedString(@"Cancel", @"Cancel  -  button title");
//    NSString *importTitle = NSLocalizedString(@"Import", @"Import  -  button title");
//    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:importTitle, nil];
//    
//    [alertView show];
//    [alertView release];
//}
//
//
//- (void)peerImporter:(PeerImporter *)peerImporter newlyImportedObjectID:(NSManagedObjectID *)newManagedObjectID {
//    
//    //    debugLog(@"%@", newManagedObjectID);
//}
//
//
//- (void)peerImporterDidFinish:(PeerImporter *)peerImporter {
//    
//    self.hasImportFinished = YES;
//    [self performSelectorOnMainThread:@selector(stopScanning) withObject:nil waitUntilDone:YES];
//    
//    NSString *message = NSLocalizedString(@"Tap to exit.", @"Tap to exit.  --  status message");
//    [self performSelectorOnMainThread:@selector(addStatusMessage:) withObject:message waitUntilDone:NO];
//}


#pragma mark - GameCodeViewController delegate

- (void)gameCodeViewController:(GameCodeViewController *)gameCodeVC gameCodeChanged:(NSUInteger)gameCode
{
    self.gameCode = gameCode;
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
//    if (buttonIndex == 0) {
//        // Cancel
//        self.isImporting = NO;
//        self.exporterInfo = nil;
//    }
//    else {
//        // Import
//        [self.peerImporter startImport];
//    }
}

@end
