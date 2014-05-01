//
//  VCommentToContentAnimator.m
//  victorious
//
//  Created by Will Long on 3/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCommentToContentAnimator.h"

#import "VCommentsContainerViewController.h"
#import "VContentViewController.h"
#import "VRootViewController.h"

@implementation VCommentToContentAnimator


- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return .5f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)context
{
    VCommentsContainerViewController *commentsContainer = (VCommentsContainerViewController*)[context viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    VContentViewController* contentVC = (VContentViewController*)[context viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [commentsContainer animateOutWithDuration:.25f
                                   completion:^(BOOL finished)
     {
         [[context containerView] addSubview:contentVC.view];
         
         [contentVC animateInWithDuration:.25f
                               completion:^(BOOL finished)
          {
              [context completeTransition:![context transitionWasCancelled]];
          }];
     }];
}

@end
