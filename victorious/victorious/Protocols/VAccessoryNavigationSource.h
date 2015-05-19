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

@end