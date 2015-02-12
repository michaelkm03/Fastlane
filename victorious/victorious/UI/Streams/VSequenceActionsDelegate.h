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
- (void)willCommentOnSequence:(VSequence *)sequence fromView:(UIView *)view;
- (void)selectedUserOnSequence:(VSequence *)sequence fromView:(UIView *)view;
- (void)willRemixSequence:(VSequence *)sequence fromView:(UIView *)view;
- (void)willShareSequence:(VSequence *)sequence fromView:(UIView *)view;
- (BOOL)hasRepostedSequence:(VSequence *)sequence;
- (void)willRepostSequence:(VSequence *)sequence fromView:(UIView *)view completion:(void(^)(BOOL))completion;
- (void)willFlagSequence:(VSequence *)sequence fromView:(UIView *)view;
- (void)hashTag:(NSString *)hashtag tappedFromSequence:(VSequence *)sequence fromView:(UIView *)view;

@end
