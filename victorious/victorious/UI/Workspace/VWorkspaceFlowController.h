//
//  VWorkspaceFlowController.h
//  victorious
//
//  Created by Michael Sena on 1/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VFlowController.h"
#import "VHasManagedDependencies.h"

#import "VImageToolController.h"
#import "VVideoToolController.h"

@class VSequence;

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
@interface VWorkspaceFlowController : NSObject <VFlowController, VHasManagedDependancies>

@end
