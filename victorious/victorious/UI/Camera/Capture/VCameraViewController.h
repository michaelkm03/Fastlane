//
//  VCameraViewController.h
//  victorious
//
//  Created by Gary Philipp on 2/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"
#import "VCameraContext.h"

typedef void (^VMediaCaptureCompletion)(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL);

@interface VCameraViewController : UIViewController <VHasManagedDependencies>

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
 YES if the user selected media from a web search.
 */
@property (nonatomic, readonly) BOOL didSelectFromWebSearch;

/**
 *  If YES, the camera will call it's completion block immediately after taking the picture/video.
 */
@property (nonatomic, assign) BOOL shouldSkipPreview;

/**
 Returns a camera controller with the given dependencyManager.
 */
+ (VCameraViewController *)cameraViewControllerPhotoVideoWithDependencyManager:(VDependencyManager *)dependencyManager;

/**
 Returns an instance of this class that will only take photos, no video.
 */
+ (VCameraViewController *)cameraViewControllerLimitedToPhotosWithDependencyManager:(VDependencyManager *)dependencyManager;

/**
 Returns an instance of this class that will only take video, no photos.
 */
+ (VCameraViewController *)cameraViewControllerLimitedToVideoWithDependencyManager:(VDependencyManager *)dependencyManager;

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
@property (nonatomic, assign) VWorkspaceFlowControllerContext context;

/**
 *  Call this to hide the search and album buttons.
 */
- (void)hideSearchAndAlbumButtons;

/**
 *  An animated version of the toolsHidden setter.
 */
- (void)setToolbarHidden:(BOOL)toolbarHidden
                animated:(BOOL)animated;

@end
