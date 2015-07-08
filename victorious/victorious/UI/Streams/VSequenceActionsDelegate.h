//
//  VSequenceActionsDelegate.h
//  victorious
//
//  Created by Will Long on 10/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSequenceActionController.h" // for VDefaultVideoEdit

@class VSequence, VHashtag, VUser;

@protocol VSequenceActionsDelegate <NSObject>

@optional

/**
 Reposts the sequence.
 @param fromView A view in which to show action sheets or other views,
 such as a login prompt if the user is not signed in.
 @param completion A callback that is called after the repost is completed, its BOOL
 parameter indicating whether the repost was successful or not.
 */
- (void)willRepostSequence:(VSequence *)sequence fromView:(UIView *)view completion:(void(^)(BOOL))completion;

- (void)willCommentOnSequence:(VSequence *)sequence fromView:(UIView *)view;

- (void)selectedUser:(VUser *)user onSequence:(VSequence *)sequence fromView:(UIView *)view;

- (void)willRemixSequence:(VSequence *)sequence fromView:(UIView *)view videoEdit:(VDefaultVideoEdit)defaultEdit;

- (void)willShareSequence:(VSequence *)sequence fromView:(UIView *)view;

- (void)willFlagSequence:(VSequence *)sequence fromView:(UIView *)view;

- (void)hashTag:(NSString *)hashtag tappedFromSequence:(VSequence *)sequence fromView:(UIView *)view;

- (void)willShowLikersForSequence:(VSequence *)sequence fromView:(UIView *)view;

- (void)willLikeSequence:(VSequence *)sequence withView:(UIView *)view completion:(void(^)(BOOL success))completion;

/**
 *  Shows any reposters for the given sequence.
 */
- (void)showRepostersForSequence:(VSequence *)sequence;

@end
