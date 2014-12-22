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
@interface VNavigationMenuItem : NSObject <VHasManagedDependancies>

@property (nonatomic, copy, readonly) NSString *title; ///< The text to display in the menu
@property (nonatomic, copy, readonly) NSString *identifier; ///< Identifier used for automation, accessibility and other non-user-facing purposes
@property (nonatomic, strong, readonly) UIImage *icon; ///< An icon to display next to the label in the menu
@property (nonatomic, strong, readonly) id destination; ///< This menu item's destination. Should be either a UIViewController subclass or an implementation of VNavigationDestination

/**
 Initializes a new instance of VNavigationMenuItem with the provided property values
 */
- (instancetype)initWithTitle:(NSString *)title identifier:(NSString *)identifier icon:(UIImage *)icon destination:(id)destination NS_DESIGNATED_INITIALIZER;

/**
 initializes a new instance of VNavigationMenuItem, reading 
 property values from the provided dependencyManager
 */
- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager;

@end
