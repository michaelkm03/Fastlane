//
//  VCameraToWorkspaceAnimator.m
//  victorious
//
//  Created by Michael Sena on 7/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCameraToWorkspaceAnimator.h"

static const NSTimeInterval kCameraShutterAnimationDuration = 0.55;

@implementation VCameraToWorkspaceAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return kCameraShutterAnimationDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    [[transitionContext containerView] addSubview:fromViewController.view];
    [[transitionContext containerView] addSubview:toViewController.view];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];

    toView.alpha = 0.0f;
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^
     {
         toView.alpha = 1.0f;
     }
                     completion:^(BOOL finished)
     {
         [transitionContext completeTransition:YES];
     }];
}

@end
