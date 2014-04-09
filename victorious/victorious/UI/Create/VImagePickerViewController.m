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

@interface VImagePickerViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
@end

@implementation VImagePickerViewController

- (instancetype)initWithType:(VImagePickerViewControllerType)type
{
    self = [super init];
    if (self)
    {
        self.type = type;
    }
    return self;
}

- (void)setType:(VImagePickerViewControllerType)type
{
    _type = type;
    
    if (_type == VImagePickerViewControllerPhoto)
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    else if (_type == VImagePickerViewControllerVideo)
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
    else
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie];
}

- (UIImagePickerController*)imagePicker
{
    if (!_imagePicker)
    {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.allowsEditing = YES;
        _imagePicker.videoMaximumDuration  = 10.0f;
    }
    
    return _imagePicker;
}

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
    
    [self dismissViewControllerAnimated:YES completion:^
    {
        [self imagePickerFinishedWithData:mediaData
                                extension:mediaType
                             previewImage:previewImage
                                 mediaURL:mediaURL];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Button Actions

- (IBAction)mediaButtonAction:(id)sender
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIActionSheet*  sheet = [[UIActionSheet alloc] initWithTitle:@"Select Using:"
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:@"Camera", @"Your Library", nil];
        [sheet showInView:self.view];
    }
    else
    {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.firstOtherButtonIndex == buttonIndex)
    {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }
    else if ((actionSheet.firstOtherButtonIndex + 1) == buttonIndex)
    {
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }
}

#pragma mark - Overrides

- (void)imagePickerFinishedWithData:(NSData*)data
                          extension:(NSString*)extension
                       previewImage:(UIImage*)previewImage
                           mediaURL:(NSURL*)mediaURL
{

}

@end
