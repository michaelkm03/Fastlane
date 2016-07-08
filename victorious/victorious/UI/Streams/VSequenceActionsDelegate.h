//
//  VSequenceActionsDelegate.h
//  victorious
//
//  Created by Will Long on 10/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSequenceActionControllerDelegate.h"

@class VSequence, VUser;

@protocol VSequenceActionsDelegate <NSObject>
@optional

- (void)willRepostSequence:(VSequence *)sequence fromView:(UIView *)view completion:(void(^)(BOOL))completion;

- (void)willCommentOnSequence:(VSequence *)sequence fromView:(UIView *)view;

- (void)selectedUser:(VUser *)user onSequence:(VSequence *)sequence fromView:(UIView *)view;

- (void)willRemixSequence:(VSequence *)sequence fromView:(UIView *)view;

- (void)willShareSequence:(VSequence *)sequence fromView:(UIView *)view;

- (void)hashTag:(NSString *)hashtag tappedFromSequence:(VSequence *)sequence fromView:(UIView *)view;

- (void)willShowLikersForSequence:(VSequence *)sequence fromView:(UIView *)view;

- (void)willLikeSequence:(VSequence *)sequence withView:(UIView *)view completion:(void(^)(BOOL success))completion;

- (void)showRepostersForSequence:(VSequence *)sequence;

- (void)willSelectMoreForSequence:(VSequence *)sequence withView:(UIView *)view completion:(void(^)(BOOL success))completion;

@end
