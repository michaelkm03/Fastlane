//
//  UIViewController+VImagePicker.m
//  victorious
//
//  Created by Will Long on 1/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AVFoundation;

#import "UIViewController+VImagePicker.h"
#import "VImagePickerController.h"

#import "VConstants.h"

@implementation UIViewController (VImagePicker)

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
    
    //Typecheck just to be safe...
    if ([picker.delegate conformsToProtocol:@protocol(VImagePickerControllerDelegate)])
    {
            [(UIViewController<VImagePickerControllerDelegate>*)picker.delegate
             imagePickerFinishedWithData:mediaData
             extension:mediaType
             previewImage:previewImage
             mediaURL:mediaURL];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
