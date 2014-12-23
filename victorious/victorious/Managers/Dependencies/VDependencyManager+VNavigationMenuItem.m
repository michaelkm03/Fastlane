//
//  VDependencyManager+VNavigationMenuItem.m
//  victorious
//
//  Created by Josh Hinman on 11/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSArray+VMap.h"
#import "VDependencyManager+VNavigationMenuItem.h"
#import "VNavigationMenuItem.h"

NSString * const VDependencyManagerMenuItemsKey = @"items";

@implementation VDependencyManager (VNavigationMenuItem)

- (NSArray *)menuItemSections
{
    NSArray *sections = [self arrayForKey:VDependencyManagerMenuItemsKey];

    if (sections == nil)
    {
        return nil;
    }
    
    NSMutableArray *menuItemSections = [[NSMutableArray alloc] initWithCapacity:sections.count];
    for (NSArray *section in sections)
    {
        if ([section isKindOfClass:[NSArray class]])
        {
            NSMutableArray *menuItems = [[NSMutableArray alloc] initWithCapacity:section.count];
            for (NSDictionary *menuItemConfiguration in section)
            {
                if ([menuItemConfiguration isKindOfClass:[NSDictionary class]])
                {
                    VDependencyManager *dependencyManager = [self childDependencyManagerWithAddedConfiguration:menuItemConfiguration];
                    [menuItems addObject:[[VNavigationMenuItem alloc] initWithDependencyManager:dependencyManager]];
                }
            };
            [menuItemSections addObject:[menuItems copy]];
        }
    }
    return [menuItemSections copy];
}

@end
