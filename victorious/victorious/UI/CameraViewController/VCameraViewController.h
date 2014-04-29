//
//  VCameraViewController.h
//  victorious
//
//  Created by Gary Philipp on 2/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VMediaPreviewViewController.h"

@interface VCameraViewController : UIViewController

/**
 This completion block will be called when the user finishes capturing media
 
 @param finished YES if the user chose media, NO if the user cancelled.
 */
@property (nonatomic, copy) VMediaCaptureCompletion completionBlock;

+ (BOOL)isCameraAvailable;

+ (VCameraViewController *)cameraViewController;

/**
 Returns an instance of this class that will only take photos, no video.
 */
+ (VCameraViewController *)cameraViewControllerLimitedToPhotos;

@end
