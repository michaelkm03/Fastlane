//
//  VFollowUserControl.h
//  victorious
//
//  Created by Michael Sena on 10/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFollowControl.h"

/**
 *  A UIControl subclass for managing the Follow/UnFollow control. Manages the display/animation of the control. Use UIControlEvents to be informed of user interactions.
 */
@interface VFollowUserControl : VFollowControl

/**
 *  The state of the control, this determines how the follow contorl should display.
 */
@property (nonatomic, assign, getter = isFollowingUser) BOOL followingUser;

/**
 *  Performs an animated transition to thew new state. Does nothing if following already is equal to the parameter.
 */
- (void)setFollowingUser:(BOOL)followingUser
                animated:(BOOL)animated;

@end
