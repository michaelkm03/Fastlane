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

static NSString *const kToolsKey = @"tools";

@implementation VDependencyManager (VWorkspaceTool)

- (NSArray /* VWorkspaceTool */ *)tools
{
    NSArray *toolConfigurations = [self arrayForKey:kToolsKey];
    
    if (toolConfigurations == nil)
    {
        return nil;
    }
    
    if (toolConfigurations.count == 0)
    {
        return nil;
    }
    
    return [toolConfigurations v_map:^id(NSDictionary *configuration)
    {
        return [self objectOfType:[NSObject class] fromDictionary:configuration];
    }];
}

@end
