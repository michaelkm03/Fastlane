//
//  VContentToCommentAnimator.m
//  victorious
//
//  Created by Will Long on 4/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentToCommentAnimator.h"

#import "VCommentsContainerViewController.h"
#import "VContentViewController.h"

@implementation VContentToCommentAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return .5f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)context
{
    VCommentsContainerViewController *commentsContainer = (VCommentsContainerViewController *)[context viewControllerForKey:UITransitionContextToViewControllerKey];
    VContentViewController *contentVC = (VContentViewController *)[context viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    commentsContainer.view.userInteractionEnabled = NO;
    contentVC.view.userInteractionEnabled = NO;
    
    [contentVC animateOutWithDuration:.5f
                           completion:^(BOOL finished)
     {
         [[context containerView] addSubview:commentsContainer.view];
         [commentsContainer animateInWithDuration:.4f
                                       completion:^(BOOL finished)
          {
              commentsContainer.view.userInteractionEnabled = YES;
              contentVC.view.userInteractionEnabled = YES;
              
              [context completeTransition:![context transitionWasCancelled]];
          }];
     }];
}

@end
