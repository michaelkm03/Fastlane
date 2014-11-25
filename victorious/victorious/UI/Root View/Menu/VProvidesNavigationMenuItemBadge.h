//
//  VProvidesNavigationMenuItemBadge.h
//  victorious
//
//  Created by Josh Hinman on 11/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^VNavigationMenuItemBadgeNumberUpdateBlock)(NSInteger badgeNumber);

/**
 Objects conforming to this protocol, when they are
 set as the destination for a navigation menu
 item, provide a number to badge that menu item.
 */
@protocol VProvidesNavigationMenuItemBadge <NSObject>

@optional

/**
 Returns a number to badge the navigation menu item.
 */
- (NSInteger)badgeNumber;

/**
 Sets a block to be called whenever the badge number changes.
 Receivers should keep a strong reference to this block and
 call it whenever the badge number needs to change.
 */
- (void)setBadgeNumberUpdateBlock:(VNavigationMenuItemBadgeNumberUpdateBlock)updateBlock;

@end
