//
//  VVCameraShutterOverAnimator.m
//  victorious
//
//  Created by Michael Sena on 1/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVCameraShutterOverAnimator.h"
#import "VWorkspaceViewController.h"

static const NSTimeInterval kBlurOverPresentTransitionDuration = 2.35f;

@implementation VVCameraShutterOverAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return kBlurOverPresentTransitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    [[transitionContext containerView] addSubview:fromViewController.view];
    [[transitionContext containerView] addSubview:toViewController.view];
    
    if ([toViewController isKindOfClass:[VWorkspaceViewController class]])
    {
        VWorkspaceViewController *workvc = (VWorkspaceViewController *)toViewController;
        workvc.snapShotView = [fromViewController.view snapshotViewAfterScreenUpdates:YES];
        [workvc bringChromeOutOfView];
    }
    UIView *snapshotView = [fromViewController.view snapshotViewAfterScreenUpdates:YES];
    [[transitionContext containerView] addSubview:snapshotView];
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.0f
         usingSpringWithDamping:0.9f
          initialSpringVelocity:-1.0f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^
     {
         if ([toViewController isKindOfClass:[VWorkspaceViewController class]])
         {
             VWorkspaceViewController *workspaceVC = (VWorkspaceViewController *)toViewController;
             [workspaceVC bringChromeIntoView];
         }
     }
                     completion:^(BOOL finished)
    {
        [transitionContext completeTransition:YES];
    }];
}

@end
