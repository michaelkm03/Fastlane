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

@class VTracking;

NS_ASSUME_NONNULL_BEGIN

extern NSString * const VDependencyManagerPositionKey;
extern NSString * const VDependencyManagerIdentifierKey;
extern NSString * const VDependencyManagerDestinationKey;
extern NSString * const VDependencyManagerIconKey;
extern NSString * const VDependencyManagerSelectedIconKey;
extern NSString * const VDependencyManagerPositionLeft;
extern NSString * const VDependencyManagerPositionRight;

/**
 An item in a navigation menu
 */
@interface VNavigationMenuItem : NSObject <VHasManagedDependencies>

@property (nonatomic, copy, readonly) NSString *title; ///< The text to display in the menu
@property (nonatomic, copy, readonly) NSString *identifier; ///< Identifier used for automation, accessibility and other non-user-facing purposes
@property (nonatomic, strong, readonly) UIImage *icon; ///< An icon to display next to the label in the menu
@property (nonatomic, strong, readonly) UIImage *selectedIcon; ///< An icon to display when selected
@property (nonatomic, strong, readonly) id destination; ///< This menu item's destination. Should be either a UIViewController subclass or an implementation of VNavigationDestination
@property (nonatomic, strong, readonly) UIColor *tintColor; ///< Template-driven color to use for `tintColor` property of bar button
@property (nonatomic, strong, readonly) NSString *position; ///< 'left' or 'right'
@property (nonatomic, strong, readonly) VDependencyManager *dependencyManager; ///< The dependency manager used to create this menu item if created from template

/**
 Initializes a new instance of VNavigationMenuItem with the provided property values
 */
- (instancetype)initWithTitle:(NSString *)title
                   identifier:(NSString *)identifier
                         icon:(UIImage *)icon
                 selectedIcon:(UIImage *)selectedIcon
                  destination:(id)destination
                     position:(NSString *)position
                    tintColor:(UIColor *)tintColor NS_DESIGNATED_INITIALIZER;

/**
 initializes a new instance of VNavigationMenuItem, reading 
 property values from the provided dependencyManager
 */
- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager;

- (instancetype)init NS_UNAVAILABLE;

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

NS_ASSUME_NONNULL_END
