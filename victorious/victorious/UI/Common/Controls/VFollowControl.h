//
//  VFollowControl.h
//  victorious
//
//  Created by Sharif Ahmed on 6/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VDependencyManager;

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
- (void)setFollowing:(BOOL)following animated:(BOOL)animated;

/**
    The dependency manager used to style and supply the follow icons for this control.
 */
@property (nonatomic, strong) VDependencyManager *dependencyManager;

/**
    The following state displayed by this control. Setting this using setFollowing:
        is equivalent to calling setFollowing:animated: with animated set to NO.
 */
@property (nonatomic, assign, getter = isFollowing) BOOL following;

@property (nonatomic, assign) BOOL showActivityIndicator;

@end