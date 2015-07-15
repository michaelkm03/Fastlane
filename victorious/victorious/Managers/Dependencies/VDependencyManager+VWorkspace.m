//
//  VDependencyManager+VWorkspace.m
//  victorious
//
//  Created by Michael Sena on 12/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager+VWorkspace.h"
//#import "VWorkspaceFlowController.h"
#import "VWorkspaceTool.h"

static NSString * const kToolsKey = @"tools";

@implementation VDependencyManager (VWorkspace)

- (NSArray /* VWorkspaceTool */ *)workspaceTools
{
    return [self arrayOfValuesConformingToProtocol:@protocol(VWorkspaceTool) forKey:kToolsKey];
}

@end
