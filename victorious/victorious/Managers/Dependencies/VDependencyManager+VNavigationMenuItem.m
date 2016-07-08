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
NSString * const VDependencyManagerAccessoryScreensKey = @"accessoryScreens";

@interface VDependencyManager ()

@property (nonatomic, strong) NSDictionary *configuration;

@end

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
    return [self menuItemsForKey:VDependencyManagerMenuItemsKey];
}

- (NSArray<VNavigationMenuItem *> *)menuItemsForKey:(NSString *)key
{
    NSArray *menuItems = [self arrayForKey:key];
    return [self menuItemsWithArrayOfDictionaryRepresentations:menuItems];
}

- (NSArray *)accessoryMenuItems
{
    return [self accessoryMenuItemsWithKey:nil];
}

- (NSArray *)accessoryMenuItemsWithKey:(NSString *)key
{
    return [self accessoryMenuItemsWithInheritance:YES
                                               key:key];
}

- (NSArray *)accessoryMenuItemsWithInheritance:(BOOL)withInheritance
{
    return [self accessoryMenuItemsWithInheritance:withInheritance
                                               key:VDependencyManagerAccessoryScreensKey];
}

- (NSArray *)accessoryMenuItemsWithInheritance:(BOOL)withInheritance
                                           key:(NSString *)key
{
    NSString *nonNullKey = key ?: VDependencyManagerAccessoryScreensKey;
    
    if ( !withInheritance )
    {
        if ( self.configuration[ nonNullKey ] == nil )
        {
            return nil;
        }
    }
    NSArray *accessoryMenuItems = [self arrayForKey:nonNullKey];
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
