//
//  VFollowHashtagControl.m
//  victorious
//
//  Created by Lawrence Leach on 12/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFollowHashtagControl.h"

@implementation VFollowHashtagControl

#pragma mark - Public Interface

- (void)setSubscribed:(BOOL)subscribed
             animated:(BOOL)animated
{
    [self setFollowing:subscribed animated:animated withAnimationBlock:nil];
}

- (void)setSubscribed:(BOOL)subscribed
{
    [self setSubscribed:subscribed animated:NO];
}

- (BOOL)isSubscribed
{
    return self.isFollowing;
}

@end
