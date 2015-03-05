//
//  VDependencyManager+VWorkspaceTool.m
//  victorious
//
//  Created by Michael Sena on 12/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager+VWorkspaceTool.h"
#import "VWorkspaceTool.h"
#import "NSArray+VMap.h"

static NSString * const kToolsKey = @"tools";

@implementation VDependencyManager (VWorkspaceTool)

- (NSArray /* VWorkspaceTool */ *)workspaceTools
{
    return [self arrayOfValuesOfType:[NSObject class] forKey:kToolsKey];
}

@end
