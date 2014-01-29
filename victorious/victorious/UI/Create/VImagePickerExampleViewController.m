//
//  VImagePickerExampleViewController.m
//  victorious
//
//  Created by Will Long on 1/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VImagePickerExampleViewController.h"

#import "VImagePickerController.h"
#import "UIViewController+VImagePicker.h"
@interface VImagePickerExampleViewController () <VImagePickerControllerDelegate>
@property (nonatomic, strong) VImagePickerController* picker;
@end

@implementation VImagePickerExampleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.picker = [[VImagePickerController alloc] init];
    self.picker.delegate = self;//Gives off a warning without #import "UIVC+VImagePicker.h"
    self.picker.type = VImagePickerControllerTypePhoto;//Optional: defaults to PhotoAndVideo
    self.picker.type = VImagePickerControllerTypeVideo;//Setter will automatically update the mediaType of
    self.picker.type = VImagePickerControllerTypePhotoAndVideo;//the UIImagePickerController
    self.picker.videoMaximumDuration = 15.0f; //Optional: defaults to 10.0f
    
    [self presentViewController:self.picker animated:YES completion:nil]; //presentation is the same
}

- (void)imagePickerFinishedWithData:(NSData*)data
                          extension:(NSString*)extension
                       previewImage:(UIImage*)previewImage
                           mediaURL:(NSURL*)mediaURL
{
    //Enter your custom code here
}
@end
