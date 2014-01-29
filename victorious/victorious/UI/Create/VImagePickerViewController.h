//
//  VImagePickerViewController.h
//  victorious
//
//  Created by Will Long on 1/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VImagePickerViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

#pragma mark - Button Actions
- (IBAction)cameraButtonAction:(id)sender;

#pragma mark - Overrides
- (void)imagePickerFinishedWithData:(NSData*)data
                          extension:(NSString*)extension
                       previewImage:(UIImage*)previewImage
                           mediaURL:(NSURL*)mediaURL;

@end
