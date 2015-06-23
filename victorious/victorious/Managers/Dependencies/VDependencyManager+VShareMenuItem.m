//
//  VDependencyManager+VShareMenuItem.m
//  victorious
//
//  Created by Sharif Ahmed on 6/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager+VShareMenuItem.h"
#import "VShareMenuItem.h"

static NSString * const kDependencyManagerShareMenuItemsKey = @"shareMenuItems";

@implementation VDependencyManager (VShareMenuItem)

- (NSArray *)shareMenuItems
{
    NSArray *menuItems = [self arrayForKey:kDependencyManagerShareMenuItemsKey];
    return [self shareMenuItemsWithArrayOfDictionaryRepresentations:menuItems];
}

- (NSArray *)shareMenuItemsWithArrayOfDictionaryRepresentations:(NSArray *)menuItemRepresentations
{
    NSMutableArray *menuItems = [[NSMutableArray alloc] initWithCapacity:menuItemRepresentations.count];
    for (NSDictionary *menuItemConfiguration in menuItemRepresentations)
    {
        if ([menuItemConfiguration isKindOfClass:[NSDictionary class]])
        {
            VDependencyManager *dependencyManager = [self childDependencyManagerWithAddedConfiguration:menuItemConfiguration];
            VShareMenuItem *shareMenuItem = [[VShareMenuItem alloc] initWithDependencyManager:dependencyManager];
            if ( shareMenuItem.shareType != VShareTypeUnknown )
            {
                [menuItems addObject:shareMenuItem];
            }
        }
    };
    return [menuItems copy];
}

@end
