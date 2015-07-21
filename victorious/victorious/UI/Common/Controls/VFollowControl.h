//
//  VFollowControl.h
//  victorious
//
//  Created by Sharif Ahmed on 6/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VDependencyManager;

typedef NS_ENUM(NSUInteger, VFollowControlState)
{
    VFollowControlStateUnfollowed,
    VFollowControlStateLoading,
    VFollowControlStateFollowed
};

/**
    A control for representing the following state of the logged in user in relation to
        a followable object (currently a hashtag or user).
 */
@interface VFollowControl : UIControl

/**
    Updates the follow control to the provided following state; animates to new state
        if animated is YES.
 
    @param following The following state this control should take on.
    @param animated Whether or not the control should animate to the new following state.
 */
- (void)setControlState:(VFollowControlState)controlState animated:(BOOL)animated;

/**
    Returns the appropriate enum value for the provided bool representing whether
        or not the object represented by this control is followed. This will never
        return the loading state.
 */
+ (VFollowControlState)controlStateForFollowing:(BOOL)following;

/**
    The dependency manager used to style and supply the follow icons for this control.
 */
@property (nonatomic, strong) VDependencyManager *dependencyManager;

/**
    The control state displayed by this control. Setting this using setControlState:
        is equivalent to calling setControlState:animated: with animated set to NO.
 */
@property (nonatomic, assign) VFollowControlState controlState;

@end