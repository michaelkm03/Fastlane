//
//  VNavigationMenuItemCell.h
//  victorious
//
//  Created by Josh Hinman on 11/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VNavigationMenuItem;

/**
 Collection view (or table view) cell subclasses
 that conform to this protocol are used to
 display instances of VNavigationMenuItem
 */
@protocol VNavigationMenuItemCell <NSObject>

@required

/**
 Sets the navigation menu item being displayed by this cell
 */
- (void)setNavigationMenuItem:(VNavigationMenuItem *)navigationMenuItem;

@optional

/**
 Sets the badge number displayed in this cell.
 */
- (void)setBadgeNumber:(NSInteger)badgeNumber;

@end
