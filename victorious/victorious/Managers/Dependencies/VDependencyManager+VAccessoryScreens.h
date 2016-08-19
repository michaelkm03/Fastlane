//
//  VDependencyManager+VAccessoryScreens.h
//  victorious
//
//  Created by Patrick Lynch on 6/1/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VNavigationMenuItem.h"
#import "VBarButton.h"

@interface VDependencyManager (VAccessoryScreens)

/**
 Adds accessory screens to the given navigation item according to this VDependencyManager's configuration.
 Should be called from viewWillAppear
 
 @param navigationItem The navigation item to configure
 @param sourceViewController The view controller currently being displayed that is requesting configuration
 */
- (void)addAccessoryScreensToNavigationItem:(UINavigationItem *)navigationItem
                           fromViewController:(UIViewController *)sourceViewController;

/**
 Returns a reference to the menu item that contains the provided identifier.
 */
- (VNavigationMenuItem *)menuItemWithIdentifier:(NSString *)identifier;

/**
 Perform a navigation as if the menu item for the corresponding identifier was selected.
 */
- (BOOL)navigateToDestinationForMenuItemIdentifier:(NSString *)menuItemIdentifier;

@end
