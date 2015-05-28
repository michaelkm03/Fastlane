//
//  VModernFlowControllerAnimationController.m
//  victorious
//
//  Created by Michael Sena on 5/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VModernFlowControllerAnimationController.h"

@implementation VModernFlowControllerAnimationController

#pragma mark - UIViewControllerAnimatedTransitioning

// This is used for percent driven interactive transitions, as well as for container controllers that have companion animations that might need to
// synchronize with the main animation.
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5f;
}

// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    if (self.popping)
    {
        [[transitionContext containerView] addSubview:toViewController.view];
        [[transitionContext containerView] sendSubviewToBack:fromViewController.view];
    }
    else
    {
        [[transitionContext containerView] addSubview:toViewController.view];
        [[transitionContext containerView] sendSubviewToBack:toViewController.view];
    }

    
    if (self.popping)
    {
        fromViewController.view.transform = CGAffineTransformIdentity;
        toViewController.view.transform = CGAffineTransformMakeTranslation(-CGRectGetWidth([transitionContext containerView].bounds), 0.0f);;
    }
    else
    {
        fromViewController.view.transform = CGAffineTransformIdentity;
        toViewController.view.transform = CGAffineTransformMakeTranslation(CGRectGetWidth([transitionContext containerView].bounds), 0.0f);;
    }
    
    void (^animations)(void) = ^void(void)
    {
        if (self.popping)
        {
            fromViewController.view.transform = CGAffineTransformMakeTranslation(CGRectGetWidth([transitionContext containerView].bounds), 0.0f);;
            toViewController.view.transform = CGAffineTransformIdentity;
        }
        else
        {
            fromViewController.view.transform = CGAffineTransformMakeTranslation(-CGRectGetWidth([transitionContext containerView].bounds), 0.0f);
            toViewController.view.transform = CGAffineTransformIdentity;
        }
    };
    
    void (^completion)(BOOL finished) = ^void(BOOL finished)
    {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        fromViewController.view.transform = CGAffineTransformIdentity;
        toViewController.view.transform = CGAffineTransformIdentity;
    };
    
    // Spring curve looks weird on interactive pop, it breaks the direct manipulation effect.
    if (self.popping)
    {
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                         animations:animations
                         completion:completion];
    }
    else
    {
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.0f
             usingSpringWithDamping:1.0f
              initialSpringVelocity:0.0f
                            options:kNilOptions
                         animations:animations
                         completion:completion];
    }
}

@end
