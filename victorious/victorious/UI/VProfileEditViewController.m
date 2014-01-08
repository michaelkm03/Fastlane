//
//  VProfileEditViewController.m
//  victorious
//
//  Created by Kevin Choi on 1/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProfileEditViewController.h"
#import "UIImage+ImageEffects.h"

@interface VProfileEditViewController ()  <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) IBOutlet UITextField* nameTextField;
@property (nonatomic, weak) IBOutlet UITextField* usernameTextField;
@property (nonatomic, weak) IBOutlet UITextField* locationTextField;
@property (nonatomic, weak) IBOutlet UITextField* taglineTextField;

@property (nonatomic, weak) IBOutlet UIImageView* profileImageView;
@property (nonatomic, weak) IBOutlet UIButton* headerButton;

@end

@implementation VProfileEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setProfileData];
    [self setHeader];
    [self setTableProperties];
}

- (BOOL)setProfileData
{
    // TODO: Set the background here using core data
    UIImageView* backgroundImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"avatar.jpg"] applyLightEffect]];
    self.tableView.backgroundView = backgroundImageView;
    // TODO: Add code to set the text data here
    return YES;
}

- (void)setHeader
{
    // Create and set the header
    self.profileImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.profileImageView.image = [UIImage imageNamed:@"avatar.jpg"];
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.layer.cornerRadius = 50.0;
    self.profileImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.profileImageView.layer.shouldRasterize = YES;
    self.profileImageView.clipsToBounds = YES;
    
    self.headerButton.layer.masksToBounds = YES;
    self.headerButton.layer.cornerRadius = 50.0;
    self.headerButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.headerButton.layer.shouldRasterize = YES;
    self.headerButton.clipsToBounds = YES;
    self.headerButton.hidden = ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (void)setTableProperties
{
    self.tableView.scrollEnabled = NO;
    self.tableView.opaque = NO;
    
    self.nameTextField.delegate = self;
    self.usernameTextField.delegate = self;
    self.locationTextField.delegate = self;
    self.taglineTextField.delegate = self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.nameTextField])
        [self.usernameTextField becomeFirstResponder];
    else if ([textField isEqual:self.usernameTextField])
        [self.locationTextField becomeFirstResponder];
    else if ([textField isEqual:self.locationTextField])
        [self.taglineTextField becomeFirstResponder];
    else if ([textField isEqual:self.taglineTextField])
    {
        // TODO: push profile info to the server here
        [self.view endEditing:YES];
        return YES;
    }

    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)cancel:(id)sender
{
    NSLog(@"Cancel button pressed");
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)done:(id)sender
{
    // TODO: Save and send profile details to the server
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)takePicture:(id)sender
{
    UIImagePickerController* controller = [[UIImagePickerController alloc] init];
    
    controller.delegate = self;
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    controller.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    controller.allowsEditing = YES;
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString* mediaType = info[UIImagePickerControllerMediaType];
    UIImage* imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare((CFStringRef)mediaType, kUTTypeImage, 0) == kCFCompareEqualTo)
        imageToSave = (UIImage *)info[UIImagePickerControllerEditedImage] ?: (UIImage *)info[UIImagePickerControllerOriginalImage];
    
    [[picker parentViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[picker parentViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
