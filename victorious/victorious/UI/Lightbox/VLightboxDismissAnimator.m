//
//  VLightboxDismissAnimator.m
//  victorious
//
//  Created by Josh Hinman on 5/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VLightboxDismissAnimator.h"
#import "VLightboxViewController.h"

@implementation VLightboxDismissAnimator

- (instancetype)initWithReferenceView:(UIView *)referenceView
{
    self = [super init];
    if (self)
    {
        self.referenceView = referenceView;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.4;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *inView = [transitionContext containerView];
    VLightboxViewController *fromViewController = (VLightboxViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    NSAssert([fromViewController isKindOfClass:[VLightboxViewController class]], @"VLightboxDismissAnimator is designed to be used exclusively with VLightboxViewController");

    [inView insertSubview:toViewController.view belowSubview:fromViewController.view];
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];

    [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext]
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionCalculationModeCubic
                              animations:^(void)
    {
        [UIView addKeyframeWithRelativeStartTime:0
                                relativeDuration:0.7
                                      animations:^(void)
        {
            fromViewController.contentView.frame = [fromViewController.contentSuperview convertRect:self.referenceView.frame fromView:self.referenceView.superview];
            fromViewController.backgroundView.alpha = 0;
        }];
        [UIView addKeyframeWithRelativeStartTime:0.7
                                relativeDuration:0.3
                                      animations:^(void)
        {
            fromViewController.contentView.alpha = 0;
        }];
    }
                     completion:^(BOOL finished)
    {
        fromViewController.contentView.alpha = 1.0f;
        [fromViewController.view removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}

- (void)setReferenceView:(UIView *)referenceView
{
    _referenceView = referenceView;
}

@end
