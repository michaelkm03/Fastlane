//
//  VDependencyManager+VNavigationItem.h
//  victorious
//
//  Created by Josh Hinman on 2/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VNavigationMenuItem.h"
#import "VAccessoryNavigationSource.h"
#import "VBarButton.h"

extern NSString * const VDependencyManagerTitleImageKey; ///< The key that specifies a title image

extern NSString * const VDependencyManagerAccessoryItemMenu;
extern NSString * const VDependencyManagerAccessoryItemCompose;
extern NSString * const VDependencyManagerAccessoryItemInbox;
extern NSString * const VDependencyManagerAccessoryItemInvite;
extern NSString * const VDependencyManagerAccessoryItemFindFriends;
extern NSString * const VDependencyManagerAccessoryItemCreatePost;
extern NSString * const VDependencyManagerAccessoryItemFollowHashtag;

@interface VDependencyManager (VNavigationItem)

/**
 Internally calls configureNavigationItem:source: with nil for navigationController.
 
 @param navigationItem the navigation item to configure
 */
- (void)configureNavigationItem:(UINavigationItem *)navigationItem;

/**
 Adds properties to the given navigation item according to this VDependencyManager's configuration.
 Things like title and titleView.
 
 @param navigationItem The navigation item to configure
 @param sourceViewController The view controller currently being displayed that is requesting configuration
 
 */
- (void)configureNavigationItem:(UINavigationItem *)navigationItem forViewController:(UIViewController *)sourceViewController;

/**
 Returns a UIBarButtonItem according that was created from the provided identifier, if it exists,
 for the provided navigation item.  Will return nil if no matching bar button item was found.
 */
- (UIBarButtonItem *)barButtonItemFromNavigationItem:(UINavigationItem *)navigationItme forIdentifier:(NSString *)identifier;

- (VBarButton *)barButtonFromNavigationItem:(UINavigationItem *)navigationItme forIdentifier:(NSString *)identifier;

/**
 Returns a reference to the menu item that contains the provided identifier.
 */
- (VNavigationMenuItem *)menuItemWithIdentifier:(NSString *)identifier;

@end
