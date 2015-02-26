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
NSString * const VDependencyManagerAccessoryMenuItemsKey = @"accessoryMenuItems";

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
            NSArray *menuItems = [self menuItemsWithArrayOfDictionaryRepresentations:section];
            [menuItemSections addObject:[menuItems copy]];
        }
    }
    return [menuItemSections copy];
}

- (NSArray *)menuItems
{
    NSArray *menuItems = [self arrayForKey:VDependencyManagerMenuItemsKey];
    return [self menuItemsWithArrayOfDictionaryRepresentations:menuItems];
}

- (NSArray *)accessoryMenuItems
{
    NSArray *accessoryMenuItems = [self arrayForKey:VDependencyManagerAccessoryMenuItemsKey];
    return [self menuItemsWithArrayOfDictionaryRepresentations:accessoryMenuItems];
}

- (NSArray *)menuItemsWithArrayOfDictionaryRepresentations:(NSArray *)menuItemRepresentations
{
    NSMutableArray *menuItems = [[NSMutableArray alloc] initWithCapacity:menuItemRepresentations.count];
    for (NSDictionary *menuItemConfiguration in menuItemRepresentations)
    {
        if ([menuItemConfiguration isKindOfClass:[NSDictionary class]])
        {
            VDependencyManager *dependencyManager = [self childDependencyManagerWithAddedConfiguration:menuItemConfiguration];
            [menuItems addObject:[[VNavigationMenuItem alloc] initWithDependencyManager:dependencyManager]];
        }
    };
    return [menuItems copy];
}

@end
