//
//  VNavigationMenuItem.h
//  victorious
//
//  Created by Josh Hinman on 11/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 An item in a navigation menu
 */
@interface VNavigationMenuItem : NSObject <VHasManagedDependencies>

@property (nonatomic, copy, readonly) NSString *title; ///< The text to display in the menu
@property (nonatomic, copy, readonly) NSString *identifier; ///< Identifier used for automation, accessibility and other non-user-facing purposes
@property (nonatomic, strong, readonly) UIImage *icon; ///< An icon to display next to the label in the menu
@property (nonatomic, strong, readonly) UIImage *selectedIcon; ///< An icon to display when selected
@property (nonatomic, strong, readonly) id destination; ///< This menu item's destination. Should be either a UIViewController subclass or an implementation of VNavigationDestination
@property (nonatomic, strong, readonly) NSString *position; ///< 'left' or 'right'

/**
 Initializes a new instance of VNavigationMenuItem with the provided property values
 */
- (instancetype)initWithTitle:(NSString *)title
                   identifier:(NSString *)identifier
                         icon:(UIImage *)icon
                 selectedIcon:(UIImage *)selectedIcon
                  destination:(id)destination
                     position:(NSString *)position NS_DESIGNATED_INITIALIZER;

/**
 initializes a new instance of VNavigationMenuItem, reading 
 property values from the provided dependencyManager
 */
- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager;

/**
 Tests whether the template-provided destination on this navigation item is in
 fact a valid view controller or other navigation desitnation, and not some 
 other kind of invalid or placeholder value.  The latter may be the case if the
 behavior is intended to be overriden.  A value of YES generally indicates
 that the default navigation behavior for this navigation item can and will be
 successful.
 */
@property (nonatomic, assign, readonly) BOOL hasValidDestination;

@end
