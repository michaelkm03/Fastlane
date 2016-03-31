//
//  VImageCameraViewController.h
//  victorious
//
//  Created by Michael Sena on 7/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCreationFlowTypes.h"
#import "VHasManagedDependencies.h"

@class VImageCameraViewController;

/**
 *  A Delegate for the image camera.
 */
@protocol VImageCameraViewControllerDelegate <NSObject>

/**
 *  Informs the delegate that the image camera has successfully captured an image 
 *  and saved it to a file URL.
 */
- (void)imageCameraViewController:(VImageCameraViewController *)imageCamera
        capturedImageWithMediaURL:(NSURL *)mediaURL
                     previewImage:(UIImage *)previewImage;

@end

/**
 *  VImageCameraViewController provides UI for capturing an image.
 */
@interface VImageCameraViewController : UIViewController <VHasManagedDependencies>

/**
 *  You MUST use this factory method to grab an imageViewController.
 */
+ (instancetype)imageCameraWithDependencyManager:(VDependencyManager *)dependencyManager
                                   cameraContext:(VCameraContext)context;

/**
 *  A delegate to be infromed of events during the lifetime of the cameraViewController.
 */
@property (nonatomic, weak) id <VImageCameraViewControllerDelegate> delegate;

@end
