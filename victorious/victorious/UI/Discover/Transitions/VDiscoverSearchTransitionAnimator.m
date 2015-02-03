//
//  VDiscoverSearchTransitionAnimator.m
//  victorious
//
//  Created by Lawrence Leach on 2/1/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDiscoverSearchTransitionAnimator.h"
#import "VUsersAndTagsSearchViewController.h"
#import "VDiscoverContainerViewController.h"

@implementation VDiscoverSearchTransitionAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    if (self.isPresenting)
    {
        VDiscoverContainerViewController *fromViewController = (VDiscoverContainerViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        VUsersAndTagsSearchViewController  *toViewController = (VUsersAndTagsSearchViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        [containerView addSubview:toViewController.view];
        toViewController.view.alpha = 0.0f;
        
        [UIView animateWithDuration:duration animations:^(void)
        {
            // Animate in Search view controller
            //fromViewController.view.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
            fromViewController.view.alpha = 0.0f;
            toViewController.view.alpha = 1.0;
            
        } completion:^(BOOL finished)
         {
             fromViewController.view.transform = CGAffineTransformIdentity;
             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
         }];
    }
    else
    {
        VUsersAndTagsSearchViewController *fromViewController = (VUsersAndTagsSearchViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        VDiscoverContainerViewController *toViewController = (VDiscoverContainerViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        // Setup the initial view states
        toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
        [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
        
        [UIView animateWithDuration:duration animations:^{
            
            // Animate out back to the Discover view controller
            fromViewController.view.alpha = 0.0f;
            toViewController.view.alpha = 1.0f;
            
        } completion:^(BOOL finished)
        {
            // Clean up
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }
}

@end
