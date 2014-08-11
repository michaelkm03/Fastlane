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
@property (nonatomic)                   BOOL                didSelectAssetFromLibrary;

+ (BOOL)isCameraAvailable;

/**
 Returns an instance of this class that will initially show a video capture screen.
 */
+ (VCameraViewController *)cameraViewController;

/**
 Returns an instance of this class that will initially show a still image capture screen.
 */
+ (VCameraViewController *)cameraViewControllerStartingWithStillCapture;

/**
 Returns an instance of this class that will only take photos, no video.
 */
+ (VCameraViewController *)cameraViewControllerLimitedToPhotos;

/**
 Returns an instance of this class that will only take video, no photos.
 */
+ (VCameraViewController *)cameraViewControllerLimitedToVideo;

@end
