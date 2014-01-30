//
//  VProfileWithEmailViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProfileWithEmailViewController.h"
#import "VUser.h"
#import "VConstants.h"

@import CoreLocation;

@interface VProfileWithEmailViewController ()   <UITextFieldDelegate, UITextViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) CLLocationManager*    locationManager;
@property (nonatomic, strong) CLGeocoder*           geoCoder;

@property (nonatomic, weak) IBOutlet    UIImageView*    profileImageView;
@property (nonatomic, weak) IBOutlet    UIButton*       cameraButton;
@property (nonatomic, weak) IBOutlet    UITextField*    usernameTextField;
@property (nonatomic, weak) IBOutlet    UITextField*    locationTextField;
@property (nonatomic, weak) IBOutlet    UITextView*     taglineTextView;
@property (nonatomic, weak) IBOutlet    UILabel*        tagLinePlaceholderLabel;
@end

@implementation VProfileWithEmailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([CLLocationManager locationServicesEnabled])
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
    
    self.usernameTextField.delegate = self;
    self.usernameTextField.text = self.profile.shortName;
    self.locationTextField.delegate = self;
    self.taglineTextView.delegate = self;
    self.taglineTextView.text = self.profile.tagline;
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

- (IBAction)done:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark - CCLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.locationManager  stopMonitoringSignificantLocationChanges];
    
    CLLocation *location = [locations lastObject];
    
    self.geoCoder = [[CLGeocoder alloc] init];
    [self.geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
    {
        CLPlacemark*    mapLocation = [placemarks firstObject];
        self.locationTextField.text = mapLocation.locality;
        
        self.geoCoder = nil;
    }];
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
