//
//  PlayerViewController.m
//  Partisans
//
//  Created by Joshua Kaden on 4/24/13.
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

#import "PlayerViewController.h"

#import "ColorPickerViewController.h"
#import "GameEnvoy.h"
#import "ImageEnvoy.h"
#import "JSKCommandParcel.h"
#import "JSKMenuViewController.h"
#import "PlayerEnvoy.h"
#import "PlayerPicklistItems.h"
#import "SlickEditView.h"
#import "SystemMessage.h"

#import <QuartzCore/QuartzCore.h>

@interface PlayerViewController () <SlickEditViewProtocol, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ColorPickerViewControllerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong) IBOutlet UIButton *changeNameButton;
@property (nonatomic, strong) IBOutlet UIButton *saveButton;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIButton *changePictureButton;
@property (nonatomic, strong) IBOutlet UILabel *imageLabel;
@property (nonatomic, strong) IBOutlet UIButton *changeFaveColorButton;
@property (nonatomic, strong) IBOutlet UIButton *switchPlayersButton;
@property (nonatomic, strong) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *editBarButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cancelBarButton;
@property (nonatomic, strong) SlickEditView *editView;
@property (nonatomic, strong) UIAlertView *changePictureAlertView;
@property (nonatomic, strong) UIAlertView *confirmDeleteAlertView;
@property (nonatomic, strong) NSString *oldName;
@property (nonatomic, strong) UIColor *oldFavoriteColor;
@property (nonatomic, strong) UIImage *oldPicture;
@property (nonatomic, strong) PlayerPicklistItems *playerPicklistItems;
@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong) UIBarButtonItem *cancelEditBarButton;
@property (nonatomic, strong) UIBarButtonItem *defaultBackButtonItem;

- (IBAction)changeNameButtonPressed:(id)sender;
- (IBAction)changePictureButtonPressed:(id)sender;
- (IBAction)changeFaveColorButtonPressed:(id)sender;
- (IBAction)saveButtonPressed:(id)sender;
- (IBAction)switchPlayersButtonPressed:(id)sender;
- (IBAction)deleteButtonPressed:(id)sender;
- (IBAction)enterEditMode:(id)sender;
- (IBAction)cancelEditMode:(id)sender;

- (void)showEditView:(id)sender;
- (void)hideEditView:(id)sender;
- (void)updateNameLabels;
- (void)enterSaveMode;
- (void)enterViewMode;
- (void)enterAddMode;
- (NSString *)defaultTitle;
- (BOOL)isDataValid;

@end

@implementation PlayerViewController

@synthesize changeNameButton = m_changeNameButton;
@synthesize saveButton = m_saveButton;
@synthesize nameLabel = m_nameLabel;
@synthesize imageView = m_imageView;
@synthesize changePictureButton = m_changePictureButton;
@synthesize imageLabel = m_imageLabel;
@synthesize changeFaveColorButton = m_changeFaveColorButton;
@synthesize editView = m_editView;
@synthesize playerEnvoy = m_playerEnvoy;
@synthesize changePictureAlertView = m_changePictureAlertView;
@synthesize confirmDeleteAlertView = m_confirmDeleteAlertView;
@synthesize oldName = m_oldName;
@synthesize oldFavoriteColor = m_oldFavoriteColor;
@synthesize oldPicture = m_oldPicture;
@synthesize playerPicklistItems = m_playerPicklistItems;
@synthesize shouldHideBackButton = m_shouldHideBackButton;
@synthesize popover = m_popover;
@synthesize cancelEditBarButton = m_cancelEditBarButton;
@synthesize defaultBackButtonItem = m_defaultBackButtonItem;
@synthesize isAnAdd = m_isAnAdd;



#pragma mark - Lifecycle


- (void)dealloc
{
    [m_editView setDelegate:nil];
    [m_changePictureAlertView setDelegate:nil];
    [m_confirmDeleteAlertView setDelegate:nil];
    [m_popover setDelegate:nil];
    
    
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
    if (!self.title)
    {
        self.title = [self defaultTitle];
    }
    [self.changeNameButton setTitle:NSLocalizedString(@"Change Name", @"Change Name  --  title") forState:UIControlStateNormal];
    [self.saveButton setTitle:NSLocalizedString(@"Save", @"Save  --  title") forState:UIControlStateNormal];
    [self.view setBackgroundColor:[SystemMessage extraLightGrayColor]];
    
    if (!self.playerEnvoy)
    {
        self.playerEnvoy = [SystemMessage playerEnvoy];
    }
    //    self.playerEnvoy.favoriteColor = self.imageLabel.backgroundColor;
    
    if (self.shouldHideBackButton)
    {
        self.navigationItem.hidesBackButton = YES;
    }
    
    if (self.isAnAdd)
    {
        [self enterAddMode];
    }
    else
    {
        [self enterViewMode];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.playerEnvoy)
    {
        self.playerEnvoy = [SystemMessage playerEnvoy];
    }
    
    [self updateNameLabels];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Private


- (BOOL)isDataValid
{
    PlayerEnvoy *playerEnvoy = self.playerEnvoy;
    if (!playerEnvoy.playerName)
    {
        return NO;
    }
    if (playerEnvoy.playerName.length == 0)
    {
        return NO;
    }
    
    return YES;
}


- (NSString *)defaultTitle
{
    if (self.isAnAdd)
    {
        return NSLocalizedString(@"New Player", @"New Player  --  title");
    }
    return NSLocalizedString(@"Player Data", @"Player Data  --  title");
}


- (void)enterAddMode
{
    [self enterEditMode:nil];
    [self.navigationItem setRightBarButtonItem:nil animated:NO];
    [self.deleteButton setHidden:YES];
}


- (void)enterViewMode
{
    [self.navigationItem setRightBarButtonItem:self.editBarButton animated:NO];
    [self.changeFaveColorButton setHidden:YES];
    [self.changeNameButton setHidden:YES];
    [self.changePictureButton setHidden:YES];
    [self.saveButton setHidden:YES];
    [self.deleteButton setHidden:YES];
    if (![SystemMessage gameEnvoy])
    {
        [self.switchPlayersButton setHidden:NO];
    }
    else
    {
        [self.switchPlayersButton setHidden:YES];
    }
}

- (void)enterSaveMode
{
    if (self.isAnAdd)
    {
        [self.navigationItem setRightBarButtonItem:nil animated:NO];
    }
    else
    {
        [self.navigationItem setRightBarButtonItem:self.cancelBarButton animated:NO];
    }
    [self.changeFaveColorButton setHidden:NO];
    [self.changeNameButton setHidden:NO];
    [self.changePictureButton setHidden:NO];
    [self.deleteButton setHidden:YES];
    [self.saveButton setHidden:![self isDataValid]];
    [self.switchPlayersButton setHidden:YES];
}


- (void)showEditView:(id)sender
{
    if (self.editView)
    {
        [self.editView removeFromSuperview];
        [self.editView setDelegate:nil];
    }
    
    if (!self.cancelEditBarButton)
    {
        UIBarButtonItem *cancelEditBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(hideEditView:)];
        self.cancelEditBarButton = cancelEditBarButton;
    }
//    if (!self.defaultBackButtonItem)
//    {
//        self.defaultBackButtonItem = self.navigationItem.leftBarButtonItem;
//    }
//    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.navigationItem.hidesBackButton = YES;
    
    [self.navigationItem setRightBarButtonItem:self.cancelEditBarButton animated:NO];
    
    CGRect frame = self.view.frame;
    frame.origin.y = frame.size.height;
    SlickEditView *editView = [[SlickEditView alloc] initWithFrame:frame];
    [editView setDelegate:self];
    [editView setTextFieldText:self.playerEnvoy.playerName];
    [editView setPlaceholder:NSLocalizedString(@"What's your name?", @"What's your name?  --  placeholder text")];
    [self.view addSubview:editView];
    self.editView = editView;
    
    [UIView animateWithDuration:0.2f
                     animations:^ {
                         CGRect frame = self.editView.frame;
                         frame.origin.y = 0.0f;
                         self.editView.frame = frame;
                     }
                     completion:^(BOOL finished) {}];
}

- (void)hideEditView:(id)sender
{
    if (self.editView)
    {
        [UIView animateWithDuration:0.2f
                         animations:^ {
                             CGRect frame = self.editView.frame;
                             frame.origin.y = frame.size.height;
                             self.editView.frame = frame;
                         }
                         completion:^(BOOL finished) {
                             [self.navigationItem setLeftBarButtonItem:self.defaultBackButtonItem animated:NO];
                             self.navigationItem.hidesBackButton = self.shouldHideBackButton;
                             if (self.isAnAdd)
                             {
                                 [self.navigationItem setRightBarButtonItem:nil animated:NO];
                             }
                             else
                             {
                                 [self.navigationItem setRightBarButtonItem:self.cancelBarButton animated:NO];
                             }
                             [self.editView removeFromSuperview];
                             [self.editView setDelegate:nil];
                         }];
    }
}


- (void)updateNameLabels
{
    PlayerEnvoy *playerEnvoy = self.playerEnvoy;
    
    if (!playerEnvoy.playerName)
    {
        [self showEditView:nil];
        return;
    }
    [self.nameLabel setText:playerEnvoy.playerName];
    
    
    if (!playerEnvoy.favoriteColor)
    {
        [playerEnvoy setFavoriteColor:[UIColor grayColor]];
    }
    [self.imageLabel setBackgroundColor:playerEnvoy.favoriteColor];
    
    if (!playerEnvoy.picture)
    {
        ImageEnvoy *imageEnvoy = [[ImageEnvoy alloc] init];
        playerEnvoy.picture = imageEnvoy;
    }
    
    if (!playerEnvoy.picture.image)
    {
        playerEnvoy.isDefaultPicture = YES;
    }
    
    if (playerEnvoy.isDefaultPicture)
    {
        self.imageLabel.text = [playerEnvoy.playerName substringToIndex:1];
        UIGraphicsBeginImageContext(self.imageLabel.bounds.size);
        [[self.imageLabel layer] renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [playerEnvoy.picture setImage:viewImage];
    }
    
    UIImage *picture = playerEnvoy.picture.image;
    [self.imageView setImage:picture];
    self.imageLabel.text = nil;
}


#pragma mark - IBActions


- (IBAction)changeNameButtonPressed:(id)sender
{
    [self showEditView:nil];
//    [self performSelector:@selector(showEditView:) withObject:nil afterDelay:0.3];
}

- (IBAction)changePictureButtonPressed:(id)sender
{
    if (!self.changePictureAlertView)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Change Picture"
                                                            message:nil //@"Would you like to change your picture?"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:
                                  @"Camera",
                                  @"Camera Roll",
                                  @"Photo Library",
                                  @"Clear", nil];
        self.changePictureAlertView = alertView;
    }
    
    [self.changePictureAlertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == self.changePictureAlertView)
    {
        [self handleChangePictureAlertView:alertView clickedButtonAtIndex:(NSInteger)buttonIndex];
    }
    
    if (alertView == self.confirmDeleteAlertView)
    {
        [self handleConfirmDeleteAlertView:alertView clickedButtonAtIndex:(NSInteger)buttonIndex];
    }
}

- (void)handleConfirmDeleteAlertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            // Cancel
            return;
            break;
            
        case 1:
            // Yes -- delete this player
            [self.playerEnvoy deletePlayer];
            self.playerEnvoy = nil;
            [[SystemMessage sharedInstance] setPlayerEnvoy:nil];
            [self.navigationController popToRootViewControllerAnimated:NO];
            break;
            
        default:
            break;
    }
}

- (void)handleChangePictureAlertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            // Cancel
            return;
            break;
            
        case 1:
            // Camera
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                UIImagePickerController *vc = [[UIImagePickerController alloc] init];
                
                [vc setDelegate:self];
                [vc setAllowsEditing:YES];
                [vc setSourceType:UIImagePickerControllerSourceTypeCamera];
                
                [self.navigationController presentViewController:vc animated:YES completion:nil];
            }
            break;
            
        case 2:
        {
            // Camera Roll
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
            {
                UIImagePickerController *vc = [[UIImagePickerController alloc] init];
                
                [vc setDelegate:self];
                [vc setAllowsEditing:YES];
                [vc setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
                
                if ([SystemMessage isPad])
                {
                    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:vc];
                    [popover setDelegate:self];
                    self.popover = popover;
                    CGRect popoverRect = self.changePictureButton.frame;
                    [self.popover presentPopoverFromRect:popoverRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
                }
                else
                {
                    [self.navigationController presentViewController:vc animated:YES completion:nil];
                }
                
            }
            break;
        }
            
        case 3:
            // Photo Library
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
            {
                UIImagePickerController *vc = [[UIImagePickerController alloc] init];
                
                [vc setDelegate:self];
                [vc setAllowsEditing:YES];
                [vc setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                
                if ([SystemMessage isPad])
                {
                    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:vc];
                    [popover setDelegate:self];
                    self.popover = popover;
                    CGRect popoverRect = self.changePictureButton.frame;
                    [self.popover presentPopoverFromRect:popoverRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
                }
                else
                {
                    [self.navigationController presentViewController:vc animated:YES completion:nil];
                }
                
            }
            break;
            
        case 4:
            // Clear
            [self.playerEnvoy.picture setImage:nil];
            [self updateNameLabels];
            [self enterSaveMode];
            break;
            
        default:
            break;
    }
}

- (IBAction)changeFaveColorButtonPressed:(id)sender
{
    ColorPickerViewController *vc = [[ColorPickerViewController alloc] initWithColor:self.playerEnvoy.favoriteColor];
    [vc setDelegate:self];
    [vc setTitle:NSLocalizedString(@"Favorite Color", @"Favorite Color  --  title")];
        
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)saveButtonPressed:(id)sender
{
    if (self.isAnAdd)
    {
        PlayerEnvoy *playerEnvoy = self.playerEnvoy;
        playerEnvoy.isDefault = YES;
        [playerEnvoy commitAndSave];
        [[SystemMessage sharedInstance] setPlayerEnvoy:playerEnvoy];
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    
    // On a change, update the image cache.
    [SystemMessage clearImageCache];
    [SystemMessage clearPlayerCache];
//    [SystemMessage cacheImage:self.imageView.image key:self.playerEnvoy.intramuralID];
  
    
    [self.playerEnvoy commitAndSave];
    [self enterViewMode];
    
    // If in a game, let the host know about this change.
    GameEnvoy *gameEnvoy = [SystemMessage gameEnvoy];
    if (gameEnvoy)
    {
        JSKCommandParcel *parcel = [[JSKCommandParcel alloc] initWithType:JSKCommandParcelTypeUpdate
                                                                       to:nil
                                                                     from:self.playerEnvoy.peerID
                                                                   object:self.playerEnvoy];
        [SystemMessage sendCommandParcel:parcel shouldAwaitResponse:NO];
    }
}


- (IBAction)switchPlayersButtonPressed:(id)sender
{
    self.playerEnvoy = nil;
    
    PlayerPicklistItems *picklistItems = [[PlayerPicklistItems alloc] init];
    JSKMenuViewController *menuViewController = [[JSKMenuViewController alloc] init];
    [menuViewController setDelegate:picklistItems];
    self.playerPicklistItems = picklistItems;
    
    [self.navigationController pushViewController:menuViewController animated:YES];
}

- (IBAction)deleteButtonPressed:(id)sender
{
    if (!self.confirmDeleteAlertView)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Player"
                                                            message:@"Are you sure you want to delete this Player?"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Yes", nil];
        self.confirmDeleteAlertView = alertView;
    }
    
    [self.confirmDeleteAlertView show];
}

- (IBAction)enterEditMode:(id)sender
{
    self.oldName = self.playerEnvoy.playerName;
    self.oldFavoriteColor = self.playerEnvoy.favoriteColor;
    self.oldPicture = self.playerEnvoy.picture.image;
    
    [self.navigationItem setRightBarButtonItem:self.cancelBarButton animated:NO];
    [self.changeFaveColorButton setHidden:NO];
    [self.changeNameButton setHidden:NO];
    [self.changePictureButton setHidden:NO];
    if (![SystemMessage gameEnvoy])
    {
        [self.deleteButton setHidden:NO];
    }
    else
    {
        [self.deleteButton setHidden:YES];
    }
    [self.saveButton setHidden:YES];
    [self.switchPlayersButton setHidden:YES];
}

- (IBAction)cancelEditMode:(id)sender
{
    self.playerEnvoy.playerName = self.oldName;
    self.playerEnvoy.favoriteColor = self.oldFavoriteColor;
    [self.playerEnvoy.picture setImage:self.oldPicture];
    
    [self.navigationItem setRightBarButtonItem:self.editBarButton animated:NO];
    [self.changeFaveColorButton setHidden:YES];
    [self.changeNameButton setHidden:YES];
    [self.changePictureButton setHidden:YES];
    [self.deleteButton setHidden:YES];
    [self.saveButton setHidden:YES];
    if (![SystemMessage gameEnvoy])
    {
        [self.switchPlayersButton setHidden:NO];
    }
    else
    {
        [self.switchPlayersButton setHidden:YES];
    }
    
    [self updateNameLabels];
}



#pragma mark - Delegate methods


- (void)colorPicked:(UIColor *)color forPicker:(ColorPickerViewController *)picker
{
    [self.playerEnvoy setFavoriteColor:color];
    [self enterSaveMode];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

//Tells the delegate that the user picked a still image or movie.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *smallerImage = [SystemMessage imageWithImage:image scaledToSizeWithSameAspectRatio:CGSizeMake(135.0, 135.0)];
    PlayerEnvoy *playerEnvoy = self.playerEnvoy;
    ImageEnvoy *imageEnvoy = playerEnvoy.picture;
    if (!imageEnvoy)
    {
        imageEnvoy = [[ImageEnvoy alloc] init];
        imageEnvoy.image = smallerImage;
        playerEnvoy.picture = imageEnvoy;
        playerEnvoy.isDefaultPicture = NO;
    }
    imageEnvoy.image = smallerImage;
    playerEnvoy.isDefaultPicture = NO;
    
    [self enterSaveMode];
    
    if (self.popover)
    {
        [self.popover dismissPopoverAnimated:YES];
        [self.popover setDelegate:nil];
        self.popover = nil;
        [self updateNameLabels];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

//Tells the delegate that the user cancelled the pick operation.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (self.popover)
    {
        [self.popover dismissPopoverAnimated:YES];
        [self.popover setDelegate:nil];
        self.popover = nil;
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)slickEditViewDidFinishEditing:(SlickEditView *)slickEditView
{
    if (!self.playerEnvoy)
    {
        self.playerEnvoy = [SystemMessage playerEnvoy];
    }
    PlayerEnvoy *playerEnvoy = self.playerEnvoy;
    
    NSString *newName = slickEditView.textFieldText;
    if (newName.length == 0)
    {
        return;
    }
    
    playerEnvoy.playerName = newName;
    
    [self enterSaveMode];
   
    [self updateNameLabels];
    
    [self hideEditView:nil];
}


@end
