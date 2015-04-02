//
//  VDependencyManager+VWorkspace.h
//  victorious
//
//  Created by Michael Sena on 12/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager.h"

@class VWorkspaceFlowController;

@interface VDependencyManager (VWorkspace)

/** 
 The top-level tools in a workspace. Each item implements the VWorkspaceTool protocol.
 */
- (NSArray /* VWorkspaceTool */ *)workspaceTools;

/**
 Returns a new VWorkspaceFlowController instance according to the template configuration
 
 @param extraDependencies Extra dependencies to pass on to the returned VWorkspaceFlowController instance
 */
- (VWorkspaceFlowController *)workspaceFlowControllerWithAddedDependencies:(NSDictionary *)extraDependencies;

@end
