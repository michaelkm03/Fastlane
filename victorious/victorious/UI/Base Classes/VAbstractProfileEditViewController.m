//
//  VProfileEditViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAbstractProfileEditViewController.h"
#import "VConstants.h"
#import "VUser.h"
#import "UIImage+ImageEffects.h"

@interface VAbstractProfileEditViewController ()
@end

@implementation VAbstractProfileEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.usernameTextField.delegate = self;
    self.locationTextField.delegate = self;
    self.taglineTextView.delegate = self;
    
    self.usernameTextField.text = self.profile.name;
    self.taglineTextView.text = self.profile.tagline;
    self.locationTextField.text = self.profile.location;

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

    NSURL*  imageURL    =   [NSURL URLWithString:self.profile.pictureUrl];
    [self.profileImageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"profile_thumb"]];

    //  Set background image
    NSMutableURLRequest* imageRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.profile.pictureUrl]];
    [imageRequest addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    UIImageView* backgroundImageView = [[UIImageView alloc] initWithFrame:self.tableView.backgroundView.frame];
    [backgroundImageView setImageWithURLRequest:imageRequest
                               placeholderImage:[[UIImage imageNamed:@"profile_full"] applyLightEffect]
                                        success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image )
                                         {
                                             [image applyLightEffect];
                                         }
                                        failure:nil];
    self.tableView.backgroundView = backgroundImageView;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
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
    if ([textField isEqual:self.usernameTextField])
        [self.locationTextField becomeFirstResponder];
    else if ([textField isEqual:self.locationTextField])
        [self.taglineTextView becomeFirstResponder];
    else
        [self.taglineTextView resignFirstResponder];
    
    return YES;
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

@end
