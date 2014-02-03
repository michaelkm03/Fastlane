//
//  VImagePickerViewController.h
//  victorious
//
//  Created by Will Long on 1/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, VImagePickerViewControllerType){
    VImagePickerViewControllerPhoto,
    VImagePickerViewControllerVideo,
    VImagePickerViewControllerPhotoAndVideo
};

@interface VImagePickerViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>


- (instancetype)initWithType:(VImagePickerViewControllerType)type;

@property (nonatomic, setter = setType:) VImagePickerViewControllerType type;

//#pragma mark - Button Actions
//- (void)mediaButtonAction:(id)sender;

#pragma mark - Overrides
- (void)imagePickerFinishedWithData:(NSData*)data
                          extension:(NSString*)extension
                       previewImage:(UIImage*)previewImage
                           mediaURL:(NSURL*)mediaURL;

@end
