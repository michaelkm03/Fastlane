//
//  VSequenceActionsDelegate.h
//  victorious
//
//  Created by Will Long on 10/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSequence, VHashtag;

@protocol VSequenceActionsDelegate <NSObject>

@optional

/**
 Returns YES if the current user has reposted this sequence before.
 As long as this sentence remains in the comment, this should only be working locally
 and will reset when the app launches until we have backend support in the next version.
 @param sequence The sequence to repost.
 */
- (BOOL)hasRepostedSequence:(VSequence *)sequence;

/**
 Reposts the sequence.
 @param fromView A view in which to show action sheets or other views,
 such as a login prompt if the user is not signed in.
 @param completion A callback that is called after the repost is completed, its BOOL
 parameter indicating whether the repost was successful or not.
 */
- (void)willRepostSequence:(VSequence *)sequence fromView:(UIView *)view completion:(void(^)(BOOL))completion;

- (void)willCommentOnSequence:(VSequence *)sequence fromView:(UIView *)view;

- (void)selectedUserOnSequence:(VSequence *)sequence fromView:(UIView *)view;

- (void)willRemixSequence:(VSequence *)sequence fromView:(UIView *)view asGif:(BOOL)gif;

- (void)willShareSequence:(VSequence *)sequence fromView:(UIView *)view;

- (void)willFlagSequence:(VSequence *)sequence fromView:(UIView *)view;

- (void)hashTag:(NSString *)hashtag tappedFromSequence:(VSequence *)sequence fromView:(UIView *)view;

@end
