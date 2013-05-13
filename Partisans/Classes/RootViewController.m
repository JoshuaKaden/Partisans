//
//  RootViewController.m
//  QuestPlayer
//
//  Created by Joshua Kaden on 4/19/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "RootViewController.h"

#import "JSKMenuViewController.h"
#import "MainMenuItems.h"
#import "PlayerEnvoy.h"
#import "PlayerViewController.h"
#import "SystemMessage.h"


@interface RootViewController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;

- (void)commence;
- (void)showFirstViewController;

@end



@implementation RootViewController


@synthesize backgroundImageView = m_backgroundImageView;



#pragma mark - View lifecycle


- (void)dealloc
{
    [m_backgroundImageView release];
    
    [super dealloc];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.backgroundImageView = nil;
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
    
    
    self.title = NSLocalizedString(@"Quest Player", @"Quest Player  --  title");
    
    // The background image.
    UIImage *image = [UIImage imageNamed:@"splash"];
    if (image)
    {
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:image];
        self.backgroundImageView = backgroundImageView;
        [backgroundImageView release];
        [self.view addSubview:self.backgroundImageView];
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.backgroundImageView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);
    
    [self commence];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}




#pragma mark - Private


- (void)commence
{
    static BOOL hasCommenced = NO;
    
    if (!hasCommenced)
    {
        PlayerEnvoy *playerEnvoy = [PlayerEnvoy defaultEnvoy];
        [[SystemMessage sharedInstance] setPlayerEnvoy:playerEnvoy];
        
        if ([SystemMessage isPlayerOnline])
        {
            // This is here to early-instantiate the Peer Controller.
            [SystemMessage resetPeerController];
        }
    }
    
    [self showFirstViewController];
    
    if (hasCommenced)
    {
        return;
    }
    
    hasCommenced = YES;
}




- (void)showFirstViewController
{
    // If there are no default players, then have the user make one.
    PlayerEnvoy *playerEnvoy = [SystemMessage playerEnvoy];
    if (!playerEnvoy)
    {
        playerEnvoy = [PlayerEnvoy defaultEnvoy];
        [[SystemMessage sharedInstance] setPlayerEnvoy:playerEnvoy];
    }
    
    if (![SystemMessage playerEnvoy].managedObjectID)
    {
        PlayerViewController *vc = [[PlayerViewController alloc] init];
        vc.shouldHideBackButton = YES;
        vc.isAnAdd = YES;
        [self.navigationController pushViewController:vc animated:NO];
        [vc release];
        return;
    }
    
    JSKMenuViewController *vc = [[JSKMenuViewController alloc] init];
    MainMenuItems *items = [[MainMenuItems alloc] init];
    [vc setMenuItems:items];
    [items release];
    [self.navigationController pushViewController:vc animated:NO];
    [vc release];
}


@end
