//
//  VAccessoryNavigationSource.h
//  victorious
//
//  Created by Patrick Lynch on 5/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import UIKit;

#import "VNavigationMenuItem.h"
#import "VAuthorizationContext.h"
#import "VProvidesNavigationMenuItemBadge.h"

/**
 This protocol is intended to be implemented by view controllers who are using template-driven
 navigation bar button items through the `accessoryMenuItems` property of their dependency manager.
 This is done primarily through VDependencyManager+VNavivationItem.  The methods in the
 protocol are called while navigation bar button items are being created and interacted with so
 that the view controller has a change to override, extend or inject dependencies in the default
 behavior.
 */
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

@optional

/**
 In cases where some kind of custom badging behavior for the navigation menu item is needed, objects
 can implement this method to provide a custom badge provider.  This custom badge prodiver will be
 used to generate and update badge values in place of the menu item's `destination`, which is
 the default provider.  This is most useful for navigation items that do not inherently have a
 destination (because they have some custom behavior that is overidden), but still want to display
 a badge to represent something about that custom behavior.
 */
- (id<VProvidesNavigationMenuItemBadge>)customBadgeProviderForMenuItem:(VNavigationMenuItem *)menuItem;

/**
 Allows a conforming object to evaluate a VNavigationItem that has just been selected
 and determine if authorization should be requires from the navigation source, i.e. itself.
 Calling code of this method will already be checking for authorization requirements on the
 VNavigationMenuItem's destination, which may want to require authorization for its own purposes.
 Implementing `menuItem:requiresAuthorizationWithContext:` allows the origin context to determine
 authorization requirements as well.  This may be necessary if, for instance, there is no destination.

 @param context A point to a VAuthorizationContext enum value that can be defined to populate the
 authorization view with appropraite content.
 */
- (BOOL)menuItem:(VNavigationMenuItem *)menuItem requiresAuthorizationWithContext:(VAuthorizationContext *)context;

/**
 Allows the bar button item for this accessory item to get created with a custom
 control. If you implement this method you are responsible for configuring everything
 about the control other than the target and action. This control will also NOT receive
 badging support.
 */
- (UIControl *)customControlForAccessoryMenuItem:(VNavigationMenuItem *)menuItem;

@end
