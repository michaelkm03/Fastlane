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

@protocol VWorkspaceFlowControllerDelegate <NSObject>

@required
- (void)workspaceFlowControllerDidCancel:(VWorkspaceFlowController *)workspaceFlowController;
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

#warning Should get rid of this when appropriate.
+ (instancetype)workspaceFlowController;

@property (nonatomic, weak) id <VWorkspaceFlowControllerDelegate> delegate;

@property (nonatomic, readonly) UIViewController *flowRootViewController;

@end
