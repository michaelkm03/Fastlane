//
//  VLoginWithSocialViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProfileWithSocialViewController.h"
#import "VInviteWithSocialViewController.h"
#import "VUser.h"
#import "VConstants.h"
#import "VThemeManager.h"
#import "UIImage+ImageEffects.h"

@interface VProfileWithSocialViewController ()
@property (nonatomic, weak) IBOutlet    UITextField*    nameTextField;
@property (nonatomic, weak) IBOutlet    UITextField*    usernameTextField;
@property (nonatomic, weak) IBOutlet    UITextField*    locationTextField;
@property (nonatomic, weak) IBOutlet    UITextView*     taglineTextView;
@property (nonatomic, weak) IBOutlet    UIImageView*    profileImageView;
@property (nonatomic, weak) IBOutlet    UIButton*       cameraButton;
@property (nonatomic, weak) IBOutlet    UISwitch*       agreeSwitch;
@property (nonatomic, weak) IBOutlet    UILabel*        tagLinePlaceholderLabel;
@end

@implementation VProfileWithSocialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.nameTextField.delegate = self;
    self.usernameTextField.delegate = self;
    self.locationTextField.delegate = self;
    self.taglineTextView.delegate = self;
    
    NSURL*  imageURL    =   [NSURL URLWithString:self.profile.pictureUrl];
    [self.profileImageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"profile_thumb"]];
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.layer.cornerRadius = 50.0;
    self.profileImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.profileImageView.layer.shouldRasterize = YES;
    self.profileImageView.clipsToBounds = YES;

    self.cameraButton.layer.masksToBounds = YES;
    self.cameraButton.layer.cornerRadius = 50.0;
    self.cameraButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.cameraButton.layer.shouldRasterize = YES;
    self.cameraButton.clipsToBounds = YES;
    
    UIImageView* backgroundImageView = [[UIImageView alloc] initWithFrame:self.tableView.backgroundView.frame];
    [backgroundImageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"profile_thumb"]];
    self.tableView.backgroundView = backgroundImageView;
}

#pragma mark - Actions

- (IBAction)takePicture:(id)sender
{
    UIImagePickerController*    picker = [[UIImagePickerController alloc] init];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    }
    else
    {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.nameTextField])
        [self.locationTextField becomeFirstResponder];
    else if ([textField isEqual:self.locationTextField])
        [self.nameTextField becomeFirstResponder];
    else if ([textField isEqual:self.nameTextField])
        [self.taglineTextView becomeFirstResponder];
    else
        [self.taglineTextView resignFirstResponder];
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    self.tagLinePlaceholderLabel.hidden = ([textView.text length] > 0);
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.tagLinePlaceholderLabel.hidden = ([textView.text length] > 0);
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* imageToSave = (UIImage *)info[UIImagePickerControllerEditedImage] ?: (UIImage *)info[UIImagePickerControllerOriginalImage];
    self.profileImageView.image = imageToSave;
    
    NSString*   mediaType   =   nil;
    NSData*     media = UIImagePNGRepresentation(imageToSave);
    if (media)
        mediaType = VConstantMediaExtensionPNG;
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Actions

- (IBAction)next:(id)sender
{
    
    [self performSegueWithIdentifier:@"toInviteWithSocial" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    VInviteWithSocialViewController*   inviteViewController = (VInviteWithSocialViewController *)segue.destinationViewController;
    inviteViewController.profile = self.profile;
}

@end
