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
    return 0.26;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *toView;
    UIView *inView = [transitionContext containerView];
    VLightboxViewController *fromViewController = (VLightboxViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    NSAssert([fromViewController isKindOfClass:[VLightboxViewController class]], @"VLightboxDismissAnimator is designed to be used exclusively with VLightboxViewController");
    
    if ([transitionContext respondsToSelector:@selector(viewForKey:)])
    {
        toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    }
    else
    {
        toView = toViewController.view;
    }
    
    if (toView)
    {
        [inView insertSubview:toView atIndex:0];
        toView.frame = [transitionContext finalFrameForViewController:toViewController];
    }
    
    UIView *contentSnapshot = [fromViewController.contentView snapshotViewAfterScreenUpdates:NO];
    contentSnapshot.center = [inView convertPoint:fromViewController.contentView.center fromView:fromViewController.contentSuperview];
    contentSnapshot.transform = fromViewController.contentSuperview.transform;
    [inView addSubview:contentSnapshot];
    fromViewController.contentView.hidden = YES;
    
    [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext]
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionCalculationModeCubic
                              animations:^(void)
    {
        [UIView addKeyframeWithRelativeStartTime:0
                                relativeDuration:0.7
                                      animations:^(void)
        {
            contentSnapshot.transform = CGAffineTransformIdentity;
            CGRect frame = [inView convertRect:self.referenceView.frame fromView:self.referenceView.superview];
            contentSnapshot.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame));
            contentSnapshot.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
            fromViewController.backgroundView.alpha = 0;
        }];
        [UIView addKeyframeWithRelativeStartTime:0.7
                                relativeDuration:0.3
                                      animations:^(void)
        {
            contentSnapshot.alpha = 0;
        }];
    }
                     completion:^(BOOL finished)
    {
        [transitionContext completeTransition:YES];
    }];
}

- (void)setReferenceView:(UIView *)referenceView
{
    _referenceView = referenceView;
}

@end
