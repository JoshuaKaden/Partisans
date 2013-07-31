//
//  GameCodeViewController.m
//  Partisans
//
//  Created by Joshua Kaden on 7/30/13.
//  Copyright (c) 2013 Chadford Software. All rights reserved.
//

#import "GameCodeViewController.h"

#import "EditCodeView.h"
#import "GameEnvoy.h"
#import "SystemMessage.h"


@interface GameCodeViewController () <EditCodeViewDelegate>

@property (nonatomic, strong) IBOutlet UILabel *gameCodeTitleLabel;
@property (nonatomic, strong) IBOutlet UILabel *gameCodeLabel;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *spinButton;

@property (nonatomic, strong) EditCodeView *editView;
@property (nonatomic, assign) NSUInteger oldGameCode;
@property (nonatomic, assign) NSUInteger newGameCode;
@property (nonatomic, strong) UIBarButtonItem *defaultBackButton;

- (IBAction)editButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)spinButtonPressed:(id)sender;

- (void)showEditView;
- (void)hideEditView;
- (void)save;
- (void)close;
- (void)saveAndClose;
- (void)updateCodeLabel:(NSUInteger)code;
- (void)spin;

@end


@implementation GameCodeViewController

@synthesize gameCodeLabel = m_gameCodeLabel;
@synthesize gameCodeTitleLabel = m_gameCodeTitleLabel;
@synthesize editButton = m_editButton;
@synthesize cancelButton = m_cancelButton;
@synthesize doneButton = m_doneButton;
@synthesize editView = m_editView;
@synthesize oldGameCode = m_oldGameCode;
@synthesize newGameCode = m_newGameCode;
@synthesize defaultBackButton = m_defaultBackButton;
@synthesize saveButton = m_saveButton;
@synthesize spinButton = m_spinButton;


- (void)dealloc
{
    self.editView.delegate = nil;
    
    [m_gameCodeLabel release];
    [m_gameCodeTitleLabel release];
    [m_editButton release];
    [m_cancelButton release];
    [m_doneButton release];
    [m_editView release];
    [m_defaultBackButton release];
    [m_saveButton release];
    [m_spinButton release];
    
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
    
    self.title = NSLocalizedString(@"Partisans", @"Partisans  --  title");
    
    GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
    [self.gameCodeTitleLabel setText:NSLocalizedString(@"The Game Code", @"The Game Code  --  label")];
    [self updateCodeLabel:gameEnvoy.gameCode];
    self.oldGameCode = gameEnvoy.gameCode;
    
    [self.spinButton setTitle:NSLocalizedString(@"Spin!", @"Spin!  --  button label")];
    
    self.defaultBackButton = self.navigationItem.backBarButtonItem;
    [self.navigationItem setRightBarButtonItem:self.editButton animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (IBAction)editButtonPressed:(id)sender
{
    [self showEditView];
    [self.navigationItem setRightBarButtonItem:self.spinButton animated:NO];
    [self.navigationItem setLeftBarButtonItem:self.cancelButton animated:NO];
}

- (IBAction)cancelButtonPressed:(id)sender
{
    if (self.editView)
    {
        if (self.editView.frame.origin.y > 0)
        {
            self.newGameCode = 0;
            [self updateCodeLabel:self.oldGameCode];
            [self.navigationItem setRightBarButtonItem:self.editButton animated:NO];
            [self.navigationItem setLeftBarButtonItem:self.defaultBackButton animated:NO];
        }
        else
        {
            [self hideEditView];
            if (self.newGameCode == self.oldGameCode || self.newGameCode == 0)
            {
                [self.navigationItem setLeftBarButtonItem:self.defaultBackButton animated:NO];
            }
            [self.navigationItem setRightBarButtonItem:self.editButton animated:NO];
        }
    }
}

- (IBAction)doneButtonPressed:(id)sender
{
    self.newGameCode = self.editView.code;
    [self updateCodeLabel:self.newGameCode];
    
    if (self.newGameCode == self.oldGameCode)
    {
        [self.navigationItem setRightBarButtonItem:self.editButton animated:NO];
        [self.navigationItem setLeftBarButtonItem:self.defaultBackButton animated:NO];
    }
    else
    {
        [self.navigationItem setRightBarButtonItem:self.saveButton animated:NO];
    }
    
    [self hideEditView];
}

- (IBAction)saveButtonPressed:(id)sender
{
    [self saveAndClose];
}

- (IBAction)spinButtonPressed:(id)sender
{
    [self spin];
}

#pragma mark - Private


- (void)spin
{
    if (!self.editView)
    {
        return;
    }
    EditCodeView *editView = self.editView;
    if (editView.frame.origin.y > 0)
    {
        return;
    }
    NSUInteger gameCode = arc4random() % (8999 + 1000);
    editView.code = gameCode;
    [editView updatePicker];
    
    [self editCodeViewValueDidChange:editView];
}

- (void)updateCodeLabel:(NSUInteger)code
{
    NSString *gameCodeString = [[NSString alloc] initWithFormat:@"%d", code];
    [self.gameCodeLabel setText:gameCodeString];
    [gameCodeString release];
}


- (void)save
{
    GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
    gameEnvoy.gameCode = self.newGameCode;
    [gameEnvoy commitAndSave];
}

- (void)close
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveAndClose
{
    [self save];
    [self close];
}


- (void)showEditView
{
    if (self.editView)
    {
        [self.editView setDelegate:nil];
        [self.editView removeFromSuperview];
        self.editView = nil;
    }
    
    CGRect frame = self.view.frame;
    frame.origin.y = frame.size.height;
    EditCodeView *editView = [[EditCodeView alloc] initWithFrame:frame];
    [editView setDelegate:self];
    editView.code = [SystemMessage gameEnvoy].gameCode;
    [self.view addSubview:editView];
    self.editView = editView;
    [editView release];
    
    [UIView animateWithDuration:0.2f
                     animations:^
    {
        CGRect frame = self.editView.frame;
        frame.origin.y = 0.0f;
        self.editView.frame = frame;
    }
    completion:^(BOOL finished){}];
}


- (void)hideEditView
{
    if (self.editView)
    {
        [UIView animateWithDuration:0.2f animations:^
        {
            CGRect frame = self.editView.frame;
            frame.origin.y = frame.size.height;
            self.editView.frame = frame;
        }
        completion:^(BOOL finished){}];
    }
}


#pragma mark - Edit View delegate

- (void)editCodeViewValueDidChange:(EditCodeView *)editView
{
    if (editView.code == self.oldGameCode)
    {
        [self.navigationItem setRightBarButtonItem:nil];
    }
    else
    {
        [self.navigationItem setRightBarButtonItem:self.doneButton animated:NO];
    }
}

@end
