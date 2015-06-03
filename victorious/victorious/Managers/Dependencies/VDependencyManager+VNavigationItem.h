//
//  VDependencyManager+VNavigationItem.h
//  victorious
//
//  Created by Josh Hinman on 2/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VNavigationMenuItem.h"

extern NSString * const VDependencyManagerTitleImageKey; ///< The key that specifies a title image

@interface VDependencyManager (VNavigationItem)

/**
 Internally calls configureNavigationItem:source: with nil for navigationController.
 
 @param navigationItem the navigation item to configure
 */
- (void)configureNavigationItem:(UINavigationItem *)navigationItem;

@end
