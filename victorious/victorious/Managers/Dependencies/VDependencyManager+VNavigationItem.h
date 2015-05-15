//
//  VDependencyManager+VNavigationItem.h
//  victorious
//
//  Created by Josh Hinman on 2/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager.h"

extern NSString * const VDependencyManagerTitleImageKey; ///< The key that specifies a title image

@protocol VAccessoryNavigationSource <NSObject>

- (BOOL)willNavigationToDestination:(id)destination;

- (BOOL)shouldDisplayAccessoryForDestination:(id)destination;

@end

@interface VDependencyManager (VNavigationItem)

/**
 Internally calls addPropertiesToNavigationItem:source: 
 with nil for navigationController.
 
 @param navigationItem the navigation item to configure
 
 */
- (void)addPropertiesToNavigationItem:(UINavigationItem *)navigationItem;

/**
 Adds properties to the given navigation item according to
 this VDependencyManager's configuration. Things like
 title and titleView.
 
 @param navigationItem the navigation item to configure
 
 @param navigationController the navigationController where accessories will be pushed on to
 
 */
- (void)addPropertiesToNavigationItem:(UINavigationItem *)navigationItem
                               source:(UIViewController *)sourceViewController;

@end
