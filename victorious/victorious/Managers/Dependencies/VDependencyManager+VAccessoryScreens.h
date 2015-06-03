//
//  VDependencyManager+VAccessoryScreens.h
//  victorious
//
//  Created by Patrick Lynch on 6/1/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VNavigationMenuItem.h"
#import "VAccessoryNavigationSource.h"
#import "VBarButton.h"

/**
 The following constants are used for identifying unique accessory screen behavior, i.e. not the
 default behavior in which the `destionation` screen provided is pushed onto the nav stack
 when the accessory button is selected.
 */
extern NSString * const VDependencyManagerAccessoryItemMenu;
extern NSString * const VDependencyManagerAccessoryItemCompose;
extern NSString * const VDependencyManagerAccessoryItemInbox;
extern NSString * const VDependencyManagerAccessoryItemInvite;
extern NSString * const VDependencyManagerAccessoryItemFindFriends;
extern NSString * const VDependencyManagerAccessoryItemCreatePost;
extern NSString * const VDependencyManagerAccessoryItemFollowHashtag;
extern NSString * const VDependencyManagerAccessoryItemMore;

@interface VDependencyManager (VAccessoryScreens)

/**
 Internally calls addAccessoryScreensToNavigationItem:fromViewController: with nil for the second parameter.
 
 @param navigationItem the navigation item to configure
 */
- (void)addAccessoryScreensToNavigationItem:(UINavigationItem *)navigationItem;

/**
 Adds properties to the given navigation item according to this VDependencyManager's configuration.
 Things like title and titleView.
 
 @param navigationItem The navigation item to configure
 @param sourceViewController The view controller currently being displayed that is requesting configuration
 */
- (void)addAccessoryScreensToNavigationItem:(UINavigationItem *)navigationItem
                         fromViewController:(UIViewController *)sourceViewController;

/**
 Returns a UIBarButtonItem according that was created from the provided identifier, if it exists,
 for the provided navigation item.  Will return nil if no matching bar button item was found.
 */
- (UIBarButtonItem *)barButtonItemFromNavigationItem:(UINavigationItem *)navigationItme forIdentifier:(NSString *)identifier;

/**
 Returns a VBarButton (a custom view designed for navivation items) that was created based
 on a menu item that matches the provider identifier.  Will return nilif no matching bar button was found.
 */
- (VBarButton *)barButtonFromNavigationItem:(UINavigationItem *)navigationItme forIdentifier:(NSString *)identifier;

/**
 Returns a reference to the menu item that contains the provided identifier.
 */
- (VNavigationMenuItem *)menuItemWithIdentifier:(NSString *)identifier;

/**
 Perform a navigation as if the menu item for the corresponding identifier was selected.
 */
- (BOOL)navigateToDestinationForMenuItemIdentifier:(NSString *)menuItemIdentifier;

@end
