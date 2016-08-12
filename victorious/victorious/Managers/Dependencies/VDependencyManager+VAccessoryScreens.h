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
extern NSString * const VDependencyManagerAccessoryNewMessage;
extern NSString * const VDependencyManagerAccessorySettings;
extern NSString * const VDependencyManagerAccessoryItemLegalInfo;

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
 Adds badging to the given navigation item according to this VDependencyManager's configuration.
 Should be called from viewDidAppear
 
 @param navigationItem The navigation item to configure
 @param sourceViewController The view controller currently being displayed that is requesting configuration
 */
- (void)addBadgingToAccessoryScreensInNavigationItem:(UINavigationItem *)navigationItem
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
