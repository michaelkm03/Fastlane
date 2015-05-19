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

extern NSString * const VDependencyManagerAccessoryItemMenu;
extern NSString * const VDependencyManagerAccessoryItemCompose;
extern NSString * const VDependencyManagerAccessoryItemInbox;
extern NSString * const VDependencyManagerAccessoryItemFindFriends;
extern NSString * const VDependencyManagerAccessoryItemAddContent;

@protocol VAccessoryNavigationSource <NSObject>

/**
 Allows a conforming object to evaluate a VNavigationMenuItem that has just been
 selected by the user and to determine if the default navigation to VNavigationMenuItem's
 destination should proceed.
 */
- (BOOL)shouldNavigateWithAccessoryMenuItem:(VNavigationMenuItem *)menuItem;

/**
 Allows a conforming object to evaluate a VNavigationMenuItem that is about to be
 used to display a navigation bar button and determine whether it should be displayed
 according to its own concerns.
 */
- (BOOL)shouldDisplayAccessoryMenuItem:(VNavigationMenuItem *)menuItem fromSource:(UIViewController *)source;

@end

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

@end
