//
//  VWorkspaceToWorkspaceAnimator.m
//  victorious
//
//  Created by Michael Sena on 2/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VWorkspaceToWorkspaceAnimator.h"

#import "VWorkspaceViewController.h"

static const NSTimeInterval kAnimationDuration = 0.35f;

@implementation VWorkspaceToWorkspaceAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return kAnimationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    VWorkspaceViewController *toWorkspace = nil;
    if ([toViewController isKindOfClass:[VWorkspaceViewController class]])
    {
        toWorkspace = (VWorkspaceViewController *)toViewController;
        [toWorkspace bringBottomChromeOutOfView];
    }
    VWorkspaceViewController *fromWorkspace = nil;
    if ([fromViewController isKindOfClass:[VWorkspaceViewController class]])
    {
        fromWorkspace = (VWorkspaceViewController *)fromViewController;
    }
    [[transitionContext containerView] addSubview:fromViewController.view];
    [[transitionContext containerView] addSubview:toViewController.view];
    toViewController.view.alpha = 0.0f;
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                     animations:^
     {
         [toWorkspace bringChromeIntoView];
         [fromWorkspace bringBottomChromeOutOfView];
         toViewController.view.alpha = 1.0f;
         fromViewController.view.alpha = 0.0f;
     }
                     completion:^(BOOL finished)
     {
         [transitionContext completeTransition:YES];
     }];
}

@end
