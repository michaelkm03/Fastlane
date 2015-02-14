//
//  VWorkspaceFlowController.h
//  victorious
//
//  Created by Michael Sena on 1/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"

#import "VImageToolController.h"
#import "VVideoToolController.h"

typedef void (^VMediaCaptureCompletion)(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL);

@class VSequence;

@class VWorkspaceFlowController;

/**
 *  A delegate for modifying the behavior of the workspace flow controller.
 */
@protocol VWorkspaceFlowControllerDelegate <NSObject>

@required

/**
 *  Notifies the delgate of a cancel. Should dismiss the workspace's rootVC here.
 */
- (void)workspaceFlowControllerDidCancel:(VWorkspaceFlowController *)workspaceFlowController;

/**
 *  Notifies the delegate that the workspaceflow is complete and ready to be dismissed.
 *
 *  @param workspaceFlowController The workspaceFlowController that just finished.
 *  @param previewImage            A preview image representing the just created content.
 *  @param capturedMediaURL        An NSURL of the location of the rendered content.
 */
- (void)workspaceFlowController:(VWorkspaceFlowController *)workspaceFlowController
       finishedWithPreviewImage:(UIImage *)previewImage
               capturedMediaURL:(NSURL *)capturedMediaURL;

@optional
- (BOOL)shouldShowPublishForWOrkspaceFlowController:(VWorkspaceFlowController *)workspaceFlowController;

@end

// Defaults
extern NSString * const VWorkspaceFlowControllerInitialCaptureStateKey;
typedef NS_ENUM(NSInteger, VWorkspaceFlowControllerInitialCaptureState)
{
    VWorkspaceFlowControllerInitialCaptureStateImage, // Default
    VWorkspaceFlowControllerInitialCaptureStateVideo
};

// Remix
extern NSString * const VWorkspaceFlowControllerSequenceToRemixKey;

// Preloaded Image
extern NSString * const VWorkspaceFlowControllerPreloadedImageKey;

/**
 *  Supports injection of:
 *
 *  - Initial capture via "VWorkspaceFlowControllerInitialCaptureStateKey",
 *  initial image edit via "VImageToolControllerInitialImageEditStateKey",
 *  initial video edit via "VVideoToolControllerInitalVideoEditStateKey",
 *  Wrap the appropriate enum value in an [NSNumber numberWithInteger:].
 *
 *  - The preview image for the workspace. This will be the image that is used during editing.
 *  Use VWorkspaceFlowControllerPreloadedImageKey with a UIImage.
 *  
 *  For remix the sequence to remix can be injected via "VWorkspaceFlowControllerSequenceToRemixKey".
 *
 */
@interface VWorkspaceFlowController : NSObject <VHasManagedDependancies>

//TODO: this is a temporary workaround for when there may not be a dependency manager.
+ (instancetype)workspaceFlowControllerWithoutADependencyManger;

/**
 *  A delegate of the workspace flow controller.
 */
@property (nonatomic, weak) id <VWorkspaceFlowControllerDelegate> delegate;

/**
 *  Present this viewcontroller. Note, the workspaceflowcontroller is not retained by this viewcontroller. So it won't be enough to merely present this viewcontroller.
 */
@property (nonatomic, readonly) UIViewController *flowRootViewController;

/**
 *  Whether or not the user should be able to select or record video.
 */
@property (nonatomic, assign, getter=isVideoEnabled) BOOL videoEnabled;

@end
