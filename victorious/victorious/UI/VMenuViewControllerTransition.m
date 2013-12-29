//
//  VMenuViewControllerTransition.m
//  victorious
//
//  Created by David Keegan on 12/24/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VMenuViewControllerTransition.h"
#import "VMenuViewController.h"
#import "UIImage+ImageEffects.h"

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

    if(self.reverse){
        VMenuViewController *menuViewController = (VMenuViewController *)fromViewController;
        [containerView insertSubview:toViewController.view belowSubview:menuViewController.view];

        [UIView animateWithDuration:animationDuration delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            menuViewController.containerView.transform = CGAffineTransformMakeTranslation(-CGRectGetMaxX(menuViewController.containerView.frame), 0);
        } completion:^(BOOL finished){
            [transitionContext completeTransition:YES];
        }];
    }else{
        VMenuViewController *menuViewController = (VMenuViewController *)toViewController;
        [containerView insertSubview:menuViewController.view aboveSubview:fromViewController.view];

        menuViewController.containerView.transform = CGAffineTransformMakeTranslation(-CGRectGetMaxX(menuViewController.containerView.frame), 0);
        [UIView animateWithDuration:animationDuration delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            menuViewController.containerView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
            [transitionContext completeTransition:YES];
        }];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.25;
}

@end
