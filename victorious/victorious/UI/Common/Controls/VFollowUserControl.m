//
//  VFollowUserControl.m
//  victorious
//
//  Created by Michael Sena on 10/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFollowUserControl.h"
#import "VDependencyManager.h"

@implementation VFollowUserControl

#pragma mark - Public Interface

- (void)setFollowingUser:(BOOL)followingUser
                animated:(BOOL)animated
{
    [self setFollowing:followingUser animated:animated withAnimationBlock:nil];
}

- (void)setFollowingUser:(BOOL)followingUser
{
    [self setFollowingUser:followingUser animated:NO];
}

- (BOOL)isFollowingUser
{
    return self.isFollowing;
}

@end
