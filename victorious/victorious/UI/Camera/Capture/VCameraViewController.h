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

/**
 If YES, the most recently captured media was
 selected from the user's asset library.
 */
@property (nonatomic, readonly) BOOL didSelectAssetFromLibrary;

/**
 *  If YES, the camera will call it's completion block immediately after taking the picture/video.
 */
@property (nonatomic, assign) BOOL shouldSkipPreview;

/**
 Returns an instance of this class that will initially show a video capture screen.
 */
+ (VCameraViewController *)cameraViewController;

/**
 Returns an instance of this class that will initially show a still image capture screen.
 */
+ (VCameraViewController *)cameraViewControllerStartingWithStillCapture;

/**
 Returns an instance of this class that will initially show a still video capture screen.
 */
+ (VCameraViewController *)cameraViewControllerStartingWithVideoCapture;

/**
 Returns an instance of this class that will only take photos, no video.
 */
+ (VCameraViewController *)cameraViewControllerLimitedToPhotos;

/**
 Returns an instance of this class that will only take video, no photos.
 */
+ (VCameraViewController *)cameraViewControllerLimitedToVideo;

/**
 YES, if the camera has exited with a fullscreen shutter animation to black. Originating form shutterCenter in this viewController's view.
 */
@property (nonatomic, readonly) BOOL showedFullscreenShutterAnimation;

/**
 The origin of the growth of the shutter animation.
 */
@property (nonatomic, readonly) CGPoint shutterCenter;

@property (nonatomic, readonly) NSURL *capturedMediaURL;

@end
