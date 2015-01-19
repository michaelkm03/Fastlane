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

/**
 *  Supports injection of:
 *  Initial capture via "VWorkspaceFlowControllerInitialCaptureStateKey",
 *  initial image edit via "VImageToolControllerInitialImageEditStateKey",
 *  initial video edit via "VVideoToolControllerInitalVideoEditStateKey",
 *  Wrap the appropriate enum value in an [NSNumber numberWithInteger:].
 *  
 *  For remix the sequence to remix can be injected via "VWorkspaceFlowControllerSequenceToRemixKey".
 *
 */
@interface VWorkspaceFlowController : NSObject <VFlowController, VHasManagedDependancies>

@end
