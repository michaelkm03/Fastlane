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
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    CGRect finalRectForToViewController = [transitionContext finalFrameForViewController:toViewController];
    
    [[transitionContext containerView] addSubview:fromView];
    [[transitionContext containerView] addSubview:toView];
    toView.frame = finalRectForToViewController;
    
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
