//
//  VDependencyManager+VNavigationMenuItem.h
//  victorious
//
//  Created by Josh Hinman on 11/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager.h"

extern NSString * const VDependencyManagerMenuItemsKey; ///< An array of arrays of menu items
extern NSString * const VDependencyManagerAccessoryScreensKey; // An arry of accessory screens on a screen

@interface VDependencyManager (VNavigationMenuItem)

/**
 Returns an array of arrays of menu items. The outer array
 represents sections in a menu, while the inner arrays
 are the items in each section. Each item is stored
 as an instance of VNavigationMenuItem.
 */
- (NSArray /* NSArray of VNavigationMenuItem */ *)menuItemSections;

/**
 Returns an array of menu items. There are no garuantees
 on the number of menu items that are returned. Each item
 is stored as an instance of VNavigationMenuItem.
 */
- (NSArray /* VNavigationMenuItems */ *)menuItems;

/**
 Returns an array of accessory menu items. These should
 be used for left/right navigation items for various screens.
 */
- (NSArray /* VNavigationMenuItems */ *)accessoryMenuItems;

@end
