//
//  VDependencyManager+VWorkspaceTool.m
//  victorious
//
//  Created by Michael Sena on 12/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager+VWorkspaceTool.h"
#import "VWorkspaceTool.h"
#import "VCategoryWorkspaceTool.h"

NSString *const VDependencyManagerWorkspaceToolsKey = @"tools";

static NSString * const kTitleKey = @"title";
static NSString * const kSubtoolsKey = @"subTools";

@implementation VDependencyManager (VWorkspaceTool)

- (NSArray *)topLevelWorkspaceTools
{
    NSArray *toolConfigurations = [self arrayForKey:VDependencyManagerWorkspaceToolsKey];
    
    if (toolConfigurations == nil)
    {
        return nil;
    }

    NSMutableArray *topLevelTools = [NSMutableArray arrayWithCapacity:toolConfigurations.count];
    for (NSDictionary *toolConfiguration in toolConfigurations)
    {
        [topLevelTools addObject:[self workspaceToolWithConfiguration:toolConfiguration]];
    }
    
    return topLevelTools;
}

- (id<VWorkspaceTool> )workspaceToolWithConfiguration:(NSDictionary *)configuration
{
    NSString *title = configuration[kTitleKey];
    
    NSArray *subToolConfigurations = configuration[kSubtoolsKey];
    NSMutableArray *subtools = [NSMutableArray arrayWithCapacity:subToolConfigurations.count];
    for (NSDictionary *subtoolConfiguration in subToolConfigurations)
    {
        [subtools addObject:[self workspaceToolWithConfiguration:subtoolConfiguration]];
    }
    
    VCategoryWorkspaceTool *tool = [[VCategoryWorkspaceTool alloc] initWithTitle:title
                                                                            icon:nil
                                                                        subTools:subtools];
    return tool;
}

@end
