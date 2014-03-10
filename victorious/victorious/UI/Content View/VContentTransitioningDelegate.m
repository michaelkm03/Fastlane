//
//  VContentTransitioningDelegate.m
//  victorious
//
//  Created by Will Long on 3/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentTransitioningDelegate.h"

#import "VCommentToContentAnimator.h"

@implementation VContentTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    VCommentToContentAnimator *animator = [[VCommentToContentAnimator alloc] init];
    return animator;
}

@end
