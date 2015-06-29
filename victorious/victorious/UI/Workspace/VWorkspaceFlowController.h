//
//  VWorkspaceFlowController.h
//  victorious
//
//  Created by Michael Sena on 1/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"
#import "VNavigationDestination.h"
#import "VAuthorizationContextProvider.h"
#import "VWorkspaceContext.h"

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

/**
 *  Asks the delegate whether or not the workspace flow should show a publish screen for
 *  creating a new sequence. If this is not implemented the workspace flow will show
 *  a publish screen.
 */
- (BOOL)shouldShowPublishForWorkspaceFlowController:(VWorkspaceFlowController *)workspaceFlowController;

@end

// Defaults
extern NSString * const VWorkspaceFlowControllerInitialCaptureStateKey;
typedef NS_ENUM(NSInteger, VWorkspaceFlowControllerInitialCaptureState)
{
    VWorkspaceFlowControllerInitialCaptureStateImage, // Default
    VWorkspaceFlowControllerInitialCaptureStateVideo,
};

// For determining how to ask for camera permissions
extern NSString * const VWorkspaceFlowControllerContextKey;

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
 *  - The context in which the workspace is being opened can be injected with
 *  the VWorkspaceFlowControllerContextKey. This used currently to control
 *  which message shows when requesting camera permissions.
 *
 *  For remix the sequence to remix can be injected via "VWorkspaceFlowControllerSequenceToRemixKey".
 */
@interface VWorkspaceFlowController : NSObject <VHasManagedDependencies, VNavigationDestination, VAuthorizationContextProvider>

/**
 *  A delegate of the workspace flow controller.
 *  ATTENTION: The delegate MUST be set otherwise the workspace flow controller will be leaked.
 */
@property (nonatomic, weak) id <VWorkspaceFlowControllerDelegate> delegate;

/**
 *  Present this viewcontroller. Note, the WorkspaceFlowController IS retained by this viewcontroller.
 *  The workspace flow controller will be deallocated after did cancel or finished is called on it's delegate.
 */
@property (nonatomic, readonly) UIViewController *flowRootViewController;

/**
 *  Whether or not the user should be able to select or record video.
 */
@property (nonatomic, assign, getter=isVideoEnabled) BOOL videoEnabled;

@end
