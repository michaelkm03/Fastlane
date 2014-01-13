//
//  VProfileEditViewController.m
//  victorious
//
//  Created by Kevin Choi on 1/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProfileEditViewController.h"
#import "UIImage+ImageEffects.h"
#import "VUser.h"

@interface VProfileEditViewController ()  <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, weak) IBOutlet UITextField* nameTextField;
@property (nonatomic, weak) IBOutlet UILabel* usernameLabel;
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
    
    [self.nameTextField becomeFirstResponder];
}

- (void)setProfileData
{
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

    //  Pre-populate fields
    self.nameTextField.text = self.profile.name;
    self.locationTextField.text = self.profile.location;
    self.taglineTextField.text = self.profile.tagline;

    //  Set UITextDelegates
    self.nameTextField.delegate = self;
    self.locationTextField.delegate = self;
    self.taglineTextField.delegate = self;
}

- (void)setHeader
{
    // Create and set the header
    NSURL*  imageURL    =   [NSURL URLWithString:self.profile.pictureUrl];
    [self.profileImageView setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"profile_thumb"]];
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
    
    self.usernameLabel.text = self.profile.shortName;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.nameTextField])
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
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    else
        controller.sourceType= UIImagePickerControllerSourceTypePhotoLibrary;
    controller.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    controller.allowsEditing = YES;
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare((CFStringRef)info[UIImagePickerControllerMediaType], kUTTypeImage, 0) == kCFCompareEqualTo)
        imageToSave = (UIImage *)info[UIImagePickerControllerEditedImage] ?: (UIImage *)info[UIImagePickerControllerOriginalImage];
    
    [[picker parentViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[picker parentViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
