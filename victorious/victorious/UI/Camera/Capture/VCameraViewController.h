//
//  VCameraViewController.h
//  victorious
//
//  Created by Gary Philipp on 2/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"
#import "VCreationTypes.h"

typedef void (^VMediaCaptureCompletion)(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL);

@interface VCameraViewController : UIViewController <VHasManagedDependencies>

/**
 *  Factory method for the camera. All parameters are required.
 *
 *  @param cameraContext A context for use in configuring permission text.
 *  @param dependencyManager A dependency manager to use for configuring templated values.
 *  @param resultHandler A handler for dealing with the results of the camera.
 */
+ (VCameraViewController *)cameraViewControllerWithContext:(VCameraContext)cameraContext
                                         dependencyManager:(VDependencyManager *)dependencyManager
                                             resultHanlder:(VMediaCaptureCompletion)resultHandler;

/**
 If YES, the most recently captured media was
 selected from the user's asset library.
 */
@property (nonatomic, readonly) BOOL didSelectAssetFromLibrary;

/**
 YES if the user selected media from a web search.
 */
@property (nonatomic, readonly) BOOL didSelectFromWebSearch;

/**
 *  If YES, the camera will call it's completion block immediately after taking the picture/video.
 */
@property (nonatomic, assign) BOOL shouldSkipPreview;

/**
 The URL of the media captured by the camera. (May be remote).
 */
@property (nonatomic, readonly) NSURL *capturedMediaURL;

/**
 A Preview image (may be lower quality than asset at capturedMediaURL).
 */
@property (nonatomic, readonly) UIImage *preivewImage;

/**
 *  A property indicating whether the camera controls are on screen.
 */
@property (nonatomic, assign, getter=isToolBarHidden) BOOL toolbarHidden;

/**
 *  A context for this cameraViewController to configure it's permission dialogs with. Defaults to
 *  VWorkspaceFlowControllerContextContentCreation.
 */
@property (nonatomic, assign, readonly) VCameraContext context;

/**
 *  An animated version of the toolsHidden setter.
 */
- (void)setToolbarHidden:(BOOL)toolbarHidden
                animated:(BOOL)animated;

@end
