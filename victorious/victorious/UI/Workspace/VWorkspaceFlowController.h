//
//  VWorkspaceFlowController.h
//  victorious
//
//  Created by Michael Sena on 1/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VFlowController.h"
#import "VHasManagedDependencies.h"

@class VSequence;

typedef NS_ENUM(NSInteger, VWorkspaceFlowControllerInitialCaptureState)
{
    VWorkspaceFlowControllerInitialCaptureStateImage,
    VWorkspaceFlowControllerInitialCaptureStateVideo
};
extern NSString * const VWorkspaceFlowControllerInitialCaptureStateKey;

//typedef NS_ENUM(NSInteger, VWorkspaceFlowControllerInitialVideoEditState)
//{
//    VWorkspaceFlowControllerInitialVideoEditStateGIF,
//};
//extern NSString * const VWorkspaceFlowControllerInitalEditStateKey;

extern NSString * const VWorkspaceFlowControllerSequenceToRemixKey;

/**
 *  Supports injection of the initial capture via "VWorkspaceFlowControllerInitialCaptureStateKey" and the sequence to remix via "VWorkspaceFlowControllerSequenceToRemixKey".
 */
@interface VWorkspaceFlowController : NSObject <VFlowController, VHasManagedDependancies>

@end
