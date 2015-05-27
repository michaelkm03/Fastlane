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
    return 0.35f;
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
        toViewController.view.transform = CGAffineTransformMakeScale(0.001f, 0.00f);
    }

    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                     animations:^
     {
         
         if (self.popping)
         {
             VLog(@"%@", [transitionContext isInteractive] ? @"YES" : @"NO");
             fromViewController.view.transform = CGAffineTransformMakeScale(0.001f, 0.001f);
             toViewController.view.transform = CGAffineTransformIdentity;
         }
         else
         {
             fromViewController.view.transform = CGAffineTransformMakeTranslation(-CGRectGetWidth([transitionContext containerView].bounds), 0.0f);
             toViewController.view.transform = CGAffineTransformIdentity;
         }
     }
                     completion:^(BOOL finished)
     {
         [transitionContext completeTransition:YES];
         fromViewController.view.transform = CGAffineTransformIdentity;
         toViewController.view.transform = CGAffineTransformIdentity;
     }];
}

@end
