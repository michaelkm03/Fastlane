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
 Asks the receiver if it is ready to be navigated to.
 
 @return YES if all systems are GO for navigation, or NO to cancel navigation.
 */
- (BOOL)shouldNavigate;

@optional

/**
 Optionally exposes a stored dependency manager of this navigation destination which
 could be used to gather data and references to other related components for larger 
 systems in the app's architecture, such as accessory screens.  Calling code should always
 check for `respondsToSelector:` and check against nil.
 */
@property (nonatomic, readonly) VDependencyManager *dependencyManager;

@end
