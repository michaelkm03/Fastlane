//
//  VPermissionAlertAnimator.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 5/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPermissionAlertAnimator.h"
#import "VPermissionAlertPresentationController.h"

@implementation VPermissionAlertAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return [self isPresentation] ? 0.3 : 0.2;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    BOOL isPresentation = [self isPresentation];
    
    UIView *animatingView = isPresentation ? toViewController.view : fromViewController.view;
    
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(0.7f, 0.7f);
    
    if (isPresentation)
    {
        animatingView.alpha = 0;
        animatingView.transform = scaleTransform;
        [containerView addSubview:animatingView];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.0f
             usingSpringWithDamping:0.6f
              initialSpringVelocity:0.0f
                            options:0
                         animations:^
         {
             animatingView.transform = CGAffineTransformIdentity;
             animatingView.alpha = 1.0f;
         } completion:^(BOOL finished)
         {
             [transitionContext completeTransition:YES];
         }];
    }
    else
    {
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^
         {
             animatingView.alpha = 0.0f;
         } completion:^(BOOL finished)
         {
             [transitionContext completeTransition:YES];
         }];
    }
}

@end

@implementation VPermissionAlertTransitionDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source
{
    VPermissionAlertAnimator *animatedTransitioner = [[VPermissionAlertAnimator alloc] init];
    animatedTransitioner.presentation = YES;
    return animatedTransitioner;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    VPermissionAlertAnimator *animatedTransitioner = [[VPermissionAlertAnimator alloc] init];
    animatedTransitioner.presentation = NO;
    return animatedTransitioner;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                      presentingViewController:(UIViewController *)presenting
                                                          sourceViewController:(UIViewController *)source
{
    return [[VPermissionAlertPresentationController alloc] initWithPresentedViewController:presented
                                                                  presentingViewController:presenting
                                                                                    source:source];
}

@end
