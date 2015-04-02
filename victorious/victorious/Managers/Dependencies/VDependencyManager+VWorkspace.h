//
//  VDependencyManager+VWorkspace.h
//  victorious
//
//  Created by Michael Sena on 12/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager.h"

@interface VDependencyManager (VWorkspace)

/** 
 The top-level tools in a workspace. Each item implements the VWorkspaceTool protocol.
 */
- (NSArray /* VWorkspaceTool */ *)workspaceTools;

@end
