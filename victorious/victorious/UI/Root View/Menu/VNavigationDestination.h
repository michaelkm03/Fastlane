//
//  VNavigationDestination.h
//  victorious
//
//  Created by Josh Hinman on 11/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 Objects (usually but not always UIViewController subclasses) conforming
 to this protocol can be specified as a destination for navigation,
 e.g. items in a menu or tab bar.
 */
@protocol VNavigationDestination <NSObject>

@optional

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
- (BOOL)shouldNavigateWithAlternateDestination:(UIViewController *__autoreleasing *)alternateViewController;

@end
