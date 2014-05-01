//
//  VUser+LoadFollowers.m
//  victorious
//
//  Created by Josh Hinman on 4/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUser+LoadFollowers.h"

#import <objc/runtime.h>

static const char kFollowerListLoadingKey;
static const char kFollowerListLoadedKey;
static const char kFollowingListLoadingKey;
static const char kFollowingListLoadedKey;

@implementation VUser (LoadFollowers)

- (BOOL)followerListLoading
{
    NSNumber *followerListLoading = objc_getAssociatedObject(self, &kFollowerListLoadingKey);
    return [followerListLoading boolValue];
}

- (void)setFollowerListLoading:(BOOL)value
{
    NSNumber *followerListLoading = [NSNumber numberWithBool:value];
    objc_setAssociatedObject(self, &kFollowerListLoadingKey, followerListLoading, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)followingListLoading
{
    NSNumber *followingListLoading = objc_getAssociatedObject(self, &kFollowingListLoadingKey);
    return [followingListLoading boolValue];
}

- (void)setFollowingListLoading:(BOOL)value
{
    NSNumber *followingListLoading = [NSNumber numberWithBool:value];
    objc_setAssociatedObject(self, &kFollowingListLoadingKey, followingListLoading, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)followerListLoaded
{
    NSNumber *followerListLoaded = objc_getAssociatedObject(self, &kFollowerListLoadedKey);
    return [followerListLoaded boolValue];
}

- (void)setFollowerListLoaded:(BOOL)value
{
    NSNumber *followerListLoaded = [NSNumber numberWithBool:value];
    objc_setAssociatedObject(self, &kFollowerListLoadedKey, followerListLoaded, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)followingListLoaded
{
    NSNumber *followingListLoaded = objc_getAssociatedObject(self, &kFollowingListLoadedKey);
    return [followingListLoaded boolValue];
}

- (void)setFollowingListLoaded:(BOOL)value
{
    NSNumber *followingListLoaded = [NSNumber numberWithBool:value];
    objc_setAssociatedObject(self, &kFollowingListLoadedKey, followingListLoaded, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
