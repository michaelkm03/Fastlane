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

/**
 *  Informs the delegate that the video camera has successfully captured an\ video
 *  and saved it to a file URL.
 */
- (void)imageCameraViewController:(VVideoCameraViewController *)imageCamera
        capturedImageWithMediaURL:(NSURL *)mediaURL
                     previewImage:(UIImage *)previewImage;

@end

@interface VVideoCameraViewController : UIViewController


#warning Should remove me and make me installed via hasmanagddep
@property (nonatomic, strong) VDependencyManager *dependencyManager;

/**
 *  You MUST use this factory method to grab a videoViewController.
 */
+ (instancetype)videoCameraWithCameraContext:(VCameraContext)context;

/**
 *  A delegate to be infromed of events during the lifetime of the cameraViewController.
 */
@property (nonatomic, weak) id <VVideoCameraViewControllerDelegate> delegate;


@end
