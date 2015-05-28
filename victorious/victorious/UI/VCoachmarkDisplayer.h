//
//  VCoachmarkDisplayer.h
//  victorious
//
//  Created by Sharif Ahmed on 5/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
    Conformance to this protocol allows conformers to the VCoachmarkDisplayResponder
    to locate this screen or menu item on screen.
 */
@protocol VCoachmarkDisplayer <NSObject>

@required

/**
    The id of the screen that conforms to this protocol.
    Under most circumstances this method should be implemented as such:
 
    - (NSString *)screenIdentifier
    {
        return [self.dependencyManager stringForKey:VDependencyManagerIDKey];
    }
 */
- (NSString *)screenIdentifier;

@optional

/**
    Returns whether or not a selector is currently visible on screen.
    Under most circumstances this method should be implemented as such:

    - (BOOL)selectorIsVisible
    {
        return !self.navigationController.navigationBarHidden;
    }
 
    Should be implemented by screens that are represented by menu items in a multi-screen selector.
 */
- (BOOL)selectorIsVisible;

@end
