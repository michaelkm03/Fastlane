//
//  VImagePickerViewController.m
//  victorious
//
//  Created by Will Long on 1/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AVFoundation;

#import "VImagePickerViewController.h"
#import "VConstants.h"

@implementation VImagePickerViewController

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString* mediaType = info[UIImagePickerControllerMediaType];
    UIImage* previewImage;
    NSData* mediaData;
    NSURL* mediaURL = info[UIImagePickerControllerMediaURL];
    // Handle image capture
    if (CFStringCompare ((CFStringRef)mediaType, kUTTypeImage, 0) == kCFCompareEqualTo)
    {
        previewImage = (UIImage *)info[UIImagePickerControllerEditedImage] ?: (UIImage *)info[UIImagePickerControllerOriginalImage];
        
        mediaData = UIImagePNGRepresentation(previewImage);
        mediaType = VConstantMediaExtensionPNG;
    }
    
    // Handle a movie capture
    if (CFStringCompare ((CFStringRef)mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo)
    {
        mediaData = [NSData dataWithContentsOfURL:mediaURL];
        mediaType = VConstantMediaExtensionMOV;
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:mediaURL options:nil];
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        gen.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMakeWithSeconds(0.0, 600);
        NSError *error = nil;
        CGImageRef image = [gen copyCGImageAtTime:time actualTime:NULL error:&error];
        if(error)
        {
            NSLog(@"%@", error);
        }
        
        previewImage = [[UIImage alloc] initWithCGImage:image];
        CGImageRelease(image);
    }
    
    [self imagePickerFinishedWithData:mediaData
                            extension:mediaType
                         previewImage:previewImage
                             mediaURL:mediaURL];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Button Actions
- (IBAction)cameraButtonAction:(id)sender
{
    UIImagePickerController* controller = [[UIImagePickerController alloc] init];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
    else
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    controller.delegate = self;
    controller.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
    controller.allowsEditing = YES;
    
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Overrides
- (void)imagePickerFinishedWithData:(NSData*)data
                          extension:(NSString*)extension
                       previewImage:(UIImage*)previewImage
                           mediaURL:(NSURL*)mediaURL
{

}

@end
