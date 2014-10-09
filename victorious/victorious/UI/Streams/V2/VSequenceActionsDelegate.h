//
//  VSequenceActionsDelegate.h
//  victorious
//
//  Created by Will Long on 10/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSequence;

@protocol VSequenceActionsDelegate <NSObject>

@optional
- (void)willCommentOnSequence:(VSequence *)sequence fromView:(UIView *)view;
- (void)selectedUserOnSequence:(VSequence *)sequence fromView:(UIView *)view;
- (void)willRemixSequence:(VSequence *)sequence fromView:(UIView *)view;
- (void)willShareSequence:(VSequence *)sequence fromView:(UIView *)view;
- (void)willRepostSequence:(VSequence *)sequence fromView:(UIView *)view;

@end
