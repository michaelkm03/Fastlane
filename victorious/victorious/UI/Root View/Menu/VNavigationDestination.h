//
//  VNavigationDestination.h
//  victorious
//
//  Created by Josh Hinman on 11/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class VDependencyManager;

/**
 Objects (usually but not always UIViewController subclasses) conforming
 to this protocol can be specified as a destination for navigation,
 e.g. items in a menu or tab bar.
 */
@protocol VNavigationDestination <NSObject>

@optional

- (NSInteger)badgeNumber;

/**
 Asks the receiver if it is ready to be navigated to. If the receiver
 is not a UIViewController subclass, it would be a programmer error
 to return YES without specifying an alternate destination via the
 alternateViewController parameter.
 
 @param alternateViewController An "out" parameter that specifies a view controller
                                that should be displayed instead of the receiver. 
                                If specified, the return value should be YES. If
                                return value is NO, all navigation is canceled including
                                to any alternate destination.
 
 @return YES if all systems are GO for navigation, or NO to cancel navigation.
 */
- (BOOL)shouldNavigateWithAlternateDestination:(id __autoreleasing *)alternateViewController;

@optional

/**
 Optionally exposes a stored dependency manager of this navigation destination which
 could be used to gather data and references to other related components for larger 
 systems in the app's architecture, such as accessory screens.  Calling code should always
 check for `respondsToSelector:` and check against nil.
 */
@property(nonatomic, readonly) VDependencyManager *dependencyManager;

/**
 Optionally exposes a stored alternate view controller of this navigation destination
 which could be used to gather data and references to other related components for larger
 systems in the app's architecture, such as deep linking.  Calling code should always
 check for `respondsToSelector:` and check against nil.
 */
- (UIViewController *)alternateViewController;

@end
