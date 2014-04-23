//
//  VCommentToStreamAnimator.m
//  victorious
//
//  Created by Will Long on 4/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCommentToStreamAnimator.h"

#import "VStreamTableViewController.h"
#import "VCommentsContainerViewController.h"

@implementation VCommentToStreamAnimator


- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return .8f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)context
{
    VCommentsContainerViewController *commentsContainer = (VCommentsContainerViewController*)[context viewControllerForKey:UITransitionContextFromViewControllerKey];
    VStreamTableViewController *streamVC = (VStreamTableViewController*)[context viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [commentsContainer animateOutWithDuration:.25f
                                   completion:^(BOOL finished)
     {
         [[context containerView] addSubview:streamVC.view];
      
         [streamVC animateInWithDuration:.4f completion:^(BOOL finished)
          {
              [context completeTransition:![context transitionWasCancelled]];
          }];
     }];
}

@end
