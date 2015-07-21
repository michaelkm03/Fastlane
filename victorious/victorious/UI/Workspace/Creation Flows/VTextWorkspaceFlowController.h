//
//  VTextWorkspaceFlowController.h
//  victorious
//
//  Created by Patrick Lynch on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCreationFlowController.h"
#import "VHasManagedDependencies.h"
#import "VNavigationDestination.h"

/**
 The top-level manager of text post creation, which creates all the tools necessary to 
 perform the process from start to completion.
 */
@interface VTextWorkspaceFlowController : VCreationFlowController <VHasManagedDependencies, VNavigationDestination>

+ (VTextWorkspaceFlowController *)textWorkspaceFlowControllerWithDependencyManager:(VDependencyManager *)dependencyManager;

@end
