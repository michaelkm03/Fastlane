//
//  VDependencyManager+VNavigationMenuItem.h
//  victorious
//
//  Created by Josh Hinman on 11/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager.h"

extern NSString * const VDependencyManagerMenuItemsKey; ///< An array of arrays of menu items

@interface VDependencyManager (VNavigationMenuItem)

/**
 Returns an array of arrays of menu items. The outer array
 represents sections in a menu, while the inner arrays
 are the items in each section. Each item is stored
 as an instance of VNavigationMenuItem
 */
- (NSArray /* NSArray of VNavigationMenuItem */ *)menuItemSections;

@end
