//
//  VImagePickerController.h
//  victorious
//
//  Created by Will Long on 1/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, VImagePickerControllerType)
{
    VImagePickerControllerTypePhoto,
    VImagePickerControllerTypeVideo,
    VImagePickerControllerTypePhotoAndVideo
};


@protocol VImagePickerControllerDelegate <NSObject>
@required
- (void)imagePickerFinishedWithData:(NSData*)data
                          extension:(NSString*)extension
                       previewImage:(UIImage*)previewImage
                           mediaURL:(NSURL*)mediaURL;
@end

@interface VImagePickerController :  UIImagePickerController

@property (nonatomic, weak) UIViewController<VImagePickerControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate> *delegate;
@property (nonatomic) VImagePickerControllerType type;

@end
