//
//  JoinGameViewController.m
//  Partisans
//
//  Created by Joshua Kaden on 5/17/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "JoinGameViewController.h"

#import "GameJoiner.h"
#import "JSKMenuViewController.h"
#import "JSKViewStack.h"
#import "SetupGameMenuItems.h"


@interface JoinGameViewController () <GameJoinerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) JSKViewStack *viewStack;
@property (nonatomic, assign) BOOL isScanning;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, assign) BOOL isFinished;

- (void)addStatusMessage:(NSString *)message;
- (void)startScanning;
- (void)stopScanning;
- (void)toggleColors;
- (void)handleTap:(UITapGestureRecognizer *)recognizer;
- (UIColor *)screenBackgroundColor;
- (UIColor *)screenTextColor;

@end


@implementation JoinGameViewController

@synthesize viewStack = m_viewStack;
@synthesize isScanning = m_isScanning;
@synthesize tapGesture = m_tapGesture;
@synthesize isFinished = m_isFinished;


#pragma mark - Boilerplate

- (void)dealloc {
    
    [m_viewStack release];
    [m_tapGesture release];
    
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
    
    self.title = NSLocalizedString(@"Game Scanner", @"Game Scanner  --  title for view controller");
    
    UIColor *backgroundColor = [UIColor blackColor];
    [self.view setBackgroundColor:backgroundColor];
    
    
    CGRect stackFrame = CGRectMake(10.0f, 10.0f, 0.0f, 0.0f);
    JSKViewStack *viewStack = [[JSKViewStack alloc] initWithFrame:stackFrame];
    
    [viewStack setBackgroundColor:backgroundColor];
    [viewStack setTextColor:[UIColor whiteColor]];
    
    self.viewStack = viewStack;
    [viewStack release];
    
    [self.view addSubview:viewStack];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    self.tapGesture = tapGesture;
    [tapGesture release];
    
    [self.view addGestureRecognizer:self.tapGesture];
    
    NSString *message = NSLocalizedString(@"Tap to start scanning.", @"Tap to start scanning.  --  status message");
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
    [label release];
}


- (void)startScanning {
    
    if (self.isScanning) {
        return;
    }
    
    self.isScanning = YES;
    
    [self toggleColors];
    
    [self.viewStack clearViews];
    
//    [self.peerImporter scanForExporter];
    
    //    [self addStatusMessage:@"Scanning for exporter..."];
    //    [self addStatusMessage:@"The exporter seems busy."];
    //    [self addStatusMessage:@"I shall try again."];
}



- (void)stopScanning {
    
    if (!self.isScanning) {
        return;
    }
    
    self.isScanning = NO;
    
    [self toggleColors];
    
//    [self.peerImporter stopScanning];
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
    
    JSKMenuViewController *vc = [[JSKMenuViewController alloc] init];
    SetupGameMenuItems *items = [[SetupGameMenuItems alloc] init];
    [vc setDelegate:items];
    [items release];
    
    [self.navigationController popViewControllerAnimated:NO];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
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
