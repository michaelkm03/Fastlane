//
//  VMenuViewControllerTransition.m
//  victorious
//
//  Created by David Keegan on 12/24/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VMenuViewControllerTransition.h"
#import "VMenuViewController.h"

@implementation VMenuViewControllerTransitionDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    VMenuViewControllerTransition *transitioning = [VMenuViewControllerTransition new];
    return transitioning;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    VMenuViewControllerTransition *transitioning = [VMenuViewControllerTransition new];
    transitioning.reverse = YES;
    return transitioning;
}

@end

@implementation VMenuViewControllerTransition

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    NSTimeInterval animationDuration = [self transitionDuration:transitionContext];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];

    if([toViewController isKindOfClass:[VMenuViewController class]]){
        [containerView insertSubview:toViewController.view aboveSubview:fromViewController.view];
        toViewController.view.transform = CGAffineTransformMakeTranslation(-CGRectGetWidth(containerView.bounds), 0);
        [UIView animateWithDuration:animationDuration delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            toViewController.view.transform = CGAffineTransformMakeTranslation(-40, 0);
        } completion:^(BOOL finished){
            [transitionContext completeTransition:YES];
        }];
    }else if([fromViewController isKindOfClass:[VMenuViewController class]]){
        [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
        [UIView animateWithDuration:animationDuration delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            fromViewController.view.transform = CGAffineTransformMakeTranslation(-CGRectGetWidth(containerView.bounds), 0);
        } completion:^(BOOL finished){
            [transitionContext completeTransition:YES];
        }];
    }else{
        [transitionContext completeTransition:YES];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.25;
}

@end
