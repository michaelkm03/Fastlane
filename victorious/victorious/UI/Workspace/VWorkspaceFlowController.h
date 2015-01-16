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

@interface VWorkspaceFlowController : NSObject <VFlowController, VHasManagedDependancies>

+ (instancetype)workspaceFlowControllerWithImageCamera;

+ (instancetype)workspaceFlowControllerWithVideoCamera;

+ (instancetype)workspaceFlowControllerWithSequenceRemix:(VSequence *)sequence;

@end
