//
//  VActionSheetPresentationAnimator.m
//  victorious
//
//  Created by Michael Sena on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VActionSheetPresentationAnimator.h"

@implementation VActionSheetPresentationAnimator


#pragma mark - UIViewControllerAnimatedTransitioning

// This is used for percent driven interactive transitions, as well as for container controllers that have companion animations that might need to
// synchronize with the main animation.
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 1.5f;
}
// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (self.presenting)
    {
        fromViewController.view.userInteractionEnabled = NO;
        
        
        [[transitionContext containerView] addSubview:fromViewController.view];
        [[transitionContext containerView] addSubview:toViewController.view];
        
        toViewController.view.frame = CGRectMake(0,
                                                 CGRectGetHeight(fromViewController.view.frame),
                                                 CGRectGetWidth(fromViewController.view.frame),
                                                 CGRectGetHeight(fromViewController.view.frame));
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                               delay:0.0f
              usingSpringWithDamping:0.7f
               initialSpringVelocity:0.0f
                             options:kNilOptions
                          animations:^{
                              toViewController.view.frame = fromViewController.view.bounds;
                          } completion:^(BOOL finished) {
                              [transitionContext completeTransition:YES];
                          }];
    }
    else
    {
        toViewController.view.userInteractionEnabled = YES;
        
        [[transitionContext containerView] addSubview:toViewController.view];
        [[transitionContext containerView] addSubview:fromViewController.view];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.0f
             usingSpringWithDamping:0.7f
              initialSpringVelocity:0.0f
                            options:kNilOptions
                         animations:^{
#warning fixme
                             fromViewController.view.frame = CGRectMake(0, 568, 320, 568);
                         } completion:^(BOOL finished) {
                             [transitionContext completeTransition:YES];
                         }];
    }
}


@end
