//
//  VDependencyManager+VNavigationItem.h
//  victorious
//
//  Created by Josh Hinman on 2/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager.h"

extern NSString * const VDependencyManagerTitleImageKey; ///< The key that specifies a title image

@interface VDependencyManager (VNavigationItem)

/**
 Adds properties to the given navigation item according to
 this VDependencyManager's configuration. Things like
 title and titleView.
 */
- (void)addPropertiesToNavigationItem:(UINavigationItem *)navigationItem;

@end
