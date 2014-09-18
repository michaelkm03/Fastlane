//
//  VSignupTransitionAnimation.m
//  victorious
//
//  Created by Gary Philipp on 6/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSignupTransitionAnimator.h"

@implementation VSignupTransitionAnimator

- (CGRect)rectForDismissedState:(id)transitionContext
{
    UIView *containerView = [transitionContext containerView];
    CGRect frame = CGRectMake(0, containerView.bounds.size.height, containerView.bounds.size.width, containerView.bounds.size.height);
    return frame;
}

- (CGRect)rectForPresentedState:(id)transitionContext
{
    UIViewController *controller;
    if (self.presenting)
    {
        controller = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    }
    else
    {
        controller = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    }
    
    CGRect frame = CGRectOffset([self rectForDismissedState:transitionContext], 0, -CGRectGetHeight(controller.view.bounds));
    return frame;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.6f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController               *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController               *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView                         *containerView = [transitionContext containerView];
    NSTimeInterval                  duration = [self transitionDuration:transitionContext];
    
    if (self.presenting)
    {
        toViewController.view.frame = [self rectForDismissedState:transitionContext];
        [containerView addSubview:toViewController.view];
        
        [UIView animateWithDuration:duration animations:^{
            toViewController.view.frame = [self rectForPresentedState:transitionContext];
         }
         completion:^(BOOL finished)
         {
             [transitionContext completeTransition:YES];
         }];
    }
    else
    {
        toViewController.view.frame = [self rectForPresentedState:transitionContext];
        [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
        
        [UIView animateWithDuration:duration animations:^{
            fromViewController.view.frame = [self rectForDismissedState:transitionContext];
         }
         completion:^(BOOL finished)
         {
             [transitionContext completeTransition:YES];
//             [fromViewController.view removeFromSuperview];
         }];
    }
}

@end
