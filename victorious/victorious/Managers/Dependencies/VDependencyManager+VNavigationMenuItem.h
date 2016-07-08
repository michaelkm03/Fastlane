//
//  VDependencyManager+VNavigationMenuItem.h
//  victorious
//
//  Created by Josh Hinman on 11/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager.h"

@class VNavigationMenuItem;

extern NSString * const VDependencyManagerMenuItemsKey; ///< An array of arrays of menu items
extern NSString * const VDependencyManagerAccessoryScreensKey; // An arry of accessory screens on a screen

@interface VDependencyManager (VNavigationMenuItem)

/**
 Returns an array of arrays of menu items. The outer array
 represents sections in a menu, while the inner arrays
 are the items in each section. Each item is stored
 as an instance of VNavigationMenuItem.
 
 @return NSArray of VNavigationMenuItem
 */
- (NSArray *)menuItemSections;

/**
 Returns an array of menu items. There are no guarantees
 on the number of menu items that are returned. Each item
 is stored as an instance of VNavigationMenuItem.
 
 @return NSArray of VNavigationMenuItem
 */
- (NSArray *)menuItems;

- (NSArray<VNavigationMenuItem *> *)menuItemsForKey:(NSString *)key;

/**
 Same as calling `accessoryMenuItemsWithKey:` with `nil`.
 */
- (NSArray *)accessoryMenuItems;

/**
 Returns an array of accessory menu items. These should
 be used for left/right navigation items for various screens.
 
 @param key A key to use for fetching accessoryMenuItems. When nil is passed defaults to "AccessoryScreens".
 
 @return NSArray of VNavigationMenuItem.
 */
- (NSArray *)accessoryMenuItemsWithKey:(NSString *)key;


/**
 Same as calling `accessoryMenuItemsWithInheritance:key:` with nil for the key parameter.
 */
- (NSArray *)accessoryMenuItemsWithInheritance:(BOOL)withInheritance;

/**
 Returns an array of accessory menu items. These should
 be used for left/right navigation items for various screens.
 
 @param withInheritance When set to NO, only acccessory menu items added to *this*
 dependency manager will be returned and not those belonging to the parent manager.
 
 @param key When a key is provided it will be used to index into the configuration for accessory menu items. 
 When nil is passed deefaults to "AccessoryScreens".
 
 @return NSArray of VNavigationMenuItem.
 */- (NSArray *)accessoryMenuItemsWithInheritance:(BOOL)withInheritance
                                              key:(NSString *)key;

@end
