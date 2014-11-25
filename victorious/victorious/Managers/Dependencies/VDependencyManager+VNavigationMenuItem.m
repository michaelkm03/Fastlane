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

static NSString * const kTitleKey = @"title";
static NSString * const kDestinationKey = @"destination";
static NSString * const kIdentifierKey = @"identifier";

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
                    NSString *title = menuItemConfiguration[kTitleKey];
                    NSString *identifier = menuItemConfiguration[kIdentifierKey];
                    id destination = [self singletonObjectOfType:[NSObject class] fromDictionary:menuItemConfiguration[kDestinationKey]];
                    
                    if (title != nil && destination != nil)
                    {
                        [menuItems addObject:[[VNavigationMenuItem alloc] initWithTitle:title identifier:identifier icon:nil destination:destination]];
                    }
                }
            };
            [menuItemSections addObject:[menuItems copy]];
        }
    }
    return [menuItemSections copy];
}

@end
