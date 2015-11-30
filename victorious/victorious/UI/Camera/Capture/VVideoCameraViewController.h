//
//  VVideoCameraViewController.h
//  victorious
//
//  Created by Michael Sena on 7/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCreationTypes.h"
#import "VHasManagedDependencies.h"

@class VVideoCameraViewController;

/**
 *  A Delegate for the video camera.
 */
@protocol VVideoCameraViewControllerDelegate <NSObject>

- (void)videoCameraViewController:(VVideoCameraViewController *)videoCamera
           capturedVideoAtFileURL:(NSURL *)url
                     previewImage:(UIImage *)previewImage;

@end

@interface VVideoCameraViewController : UIViewController <VHasManagedDependencies>

/**
 *  You MUST use this factory method to grab a videoViewController.
 */
+ (instancetype)videoCameraWithDependencyManager:(VDependencyManager *)dependencyManager
                                   cameraContext:(VCameraContext)context;

/**
 *  A delegate to be informed of events during the lifetime of the cameraViewController.
 */
@property (nonatomic, weak) id <VVideoCameraViewControllerDelegate> delegate;

/**
 *  The URL the video recorded by the video camera was saved to.
 */
@property (nonatomic, readonly) NSURL *savedVideoURL;

/**
 *  A preview image to use representing the captured video. Attempts to capture a frame near time 0.
 */
@property (nonatomic, readonly) UIImage *previewImage;

/**
 * The total recorded time of the current video
 */
@property (nonatomic, readonly) Float64 totalTimeRecorded;

@end

/**
 *  If the current user is a creator we need some extra functionality to update the state of the camera.
 */
@interface VVideoCameraViewController (CreatorExtensions)

/**
 *  Should be called after the video camera leaves the screen (ONLY WHEN IN CREATOR MODE). This behavior 
 *  is automatic on view lifecycle methods when not in creator mode.
 */
- (void)clearCaptureState;

/**
 *  Should be called when the video camera will return to the forefront (ONLY WHEN IN CREATOR MODE). This behavior
 *  is automatic on view lifecycle methods when not in creator mode.
 */
- (void)resumeCapture;

@end
