//
//  VDependencyManager+VShareMenuItem.h
//  victorious
//
//  Created by Sharif Ahmed on 6/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager.h"

@interface VDependencyManager (VShareMenuItem)

/**
 Returns an array of menu items. There are no guarantees
 on the number of menu items that are returned. Each item
 is stored as an instance of VNavigationMenuItem.
 
 @return NSArray of VShareMenuItems
 */
- (NSArray *)shareMenuItems;

@end
