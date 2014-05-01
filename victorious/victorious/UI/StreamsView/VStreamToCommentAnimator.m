//
//  VStreamToCommentAnimator.m
//  victorious
//
//  Created by Will Long on 4/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamToCommentAnimator.h"

#import "VStreamTableViewController.h"
#import "VCommentsContainerViewController.h"

#import "VStreamViewCell.h"

@implementation VStreamToCommentAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return .4f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)context
{
    VStreamTableViewController *streamVC = (VStreamTableViewController*)[context viewControllerForKey:UITransitionContextFromViewControllerKey];
    VCommentsContainerViewController* commentVC = (VCommentsContainerViewController*)[context viewControllerForKey:UITransitionContextToViewControllerKey];

     [streamVC animateOutWithDuration:.4f
                           completion:^(BOOL finished)
     {
         [[context containerView] addSubview:commentVC.view];
         [commentVC animateInWithDuration:.4f
                               completion:^(BOOL finished)
         {
             [context completeTransition:![context transitionWasCancelled]];
         }];
     }];
}

@end
