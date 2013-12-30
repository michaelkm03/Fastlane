//
//  VActionViewControllerTransition.m
//  victorious
//
//  Created by David Keegan on 12/30/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VActionViewControllerTransition.h"
#import "VAddActionViewController.h"
#import "AMBlurView.h"

@implementation VActionViewControllerTransitionDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    VActionViewControllerTransition *transitioning = [VActionViewControllerTransition new];
    return transitioning;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    VActionViewControllerTransition *transitioning = [VActionViewControllerTransition new];
    transitioning.reverse = YES;
    return transitioning;
}

@end

@implementation VActionViewControllerTransition

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    NSTimeInterval animationDuration = [self transitionDuration:transitionContext];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];

    if(self.reverse){
        VAddActionViewController *viewController = (VAddActionViewController *)fromViewController;
        [containerView insertSubview:toViewController.view belowSubview:viewController.view];

        [UIView animateWithDuration:animationDuration animations:^{
            viewController.coverView.alpha = 0;
        }];

        [UIView animateWithDuration:animationDuration delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        viewController.contentView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(viewController.contentView.bounds));            
        } completion:^(BOOL finished){
            [transitionContext completeTransition:YES];
        }];
    }else{
        VAddActionViewController *viewController = (VAddActionViewController *)toViewController;
        [containerView insertSubview:viewController.view aboveSubview:fromViewController.view];

        viewController.coverView.alpha = 0;
        [UIView animateWithDuration:animationDuration animations:^{
            viewController.coverView.alpha = 1;
        }];

        viewController.contentView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(viewController.contentView.bounds));
        [UIView animateWithDuration:animationDuration delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            viewController.contentView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
            [transitionContext completeTransition:YES];
        }];
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.25;
}

@end
