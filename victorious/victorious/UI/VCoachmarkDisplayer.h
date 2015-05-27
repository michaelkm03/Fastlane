//
//  VCoachmarkDisplayer.h
//  victorious
//
//  Created by Sharif Ahmed on 5/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
    The key used to access the id of a screen from a dependency manager
 */
static NSString * const VScreenIdentifierKey = @"id";

/**
    Conformance to this protocol allows conformers to the VCoachmarkDisplayResponder
    to locate this screen or menu item on screen.
 */
@protocol VCoachmarkDisplayer <NSObject>

/**
    The id of the screen that conforms to this protocol.
    Under most circumstances this method should be implemented as such:
 
    - (NSString *)screenIdentifier
    {
        return [self.dependencyManager stringForKey:VScreenIdentifierKey];
    }
 */
@required
- (NSString *)screenIdentifier;

/**
    Returns whether or not a selector is currently visible on screen.
    Under most circumstances this method should be implemented as such:

    - (BOOL)selectorIsVisible
    {
        return !self.navigationController.navigationBarHidden;
    }
 
    Should be implmented by screens that are represented by menu items in a multi-screen selector.
 */
@optional
- (BOOL)selectorIsVisible;

@end
