//
//  VDependencyManager+VWorkspaceTool.h
//  victorious
//
//  Created by Michael Sena on 12/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager.h"

extern NSString *const VDependencyManagerWorkspaceToolsKey;

@interface VDependencyManager (VWorkspaceTool)

- (NSArray /* NSArray of VWorkspaceTools */ *)topLevelWorkspaceTools;

@end
