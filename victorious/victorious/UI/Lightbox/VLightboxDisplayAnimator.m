//
//  VLightboxDisplayAnimator.m
//  victorious
//
//  Created by Josh Hinman on 5/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIImage+ImageEffects.h"
#import "VLightboxViewController.h"
#import "VLightboxDisplayAnimator.h"

@implementation VLightboxDisplayAnimator

- (instancetype)initWithReferenceView:(UIView *)referenceView
{
    self = [super init];
    if (self)
    {
        _referenceView = referenceView;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.2;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *toView;
    UIView *inView = [transitionContext containerView];
    VLightboxViewController *toViewController = (VLightboxViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    NSAssert([toViewController isKindOfClass:[VLightboxViewController class]], @"VLightboxDisplayAnimator is designed to be used exclusively with VLightboxViewController");
    
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
        toView.frame = [transitionContext finalFrameForViewController:toViewController];
        [inView addSubview:toView];
        [toView layoutIfNeeded];
    }
    
    CGRect frameForContentView = toViewController.contentView.frame;
    toViewController.backgroundView.alpha = 0;
    toViewController.contentView.frame = [self.referenceView.superview convertRect:self.referenceView.frame toView:toViewController.contentSuperview];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^(void)
    {
        toViewController.backgroundView.alpha = 1.0f;
        toViewController.contentView.frame = frameForContentView;
    }
                     completion:^(BOOL finished)
    {
        [transitionContext completeTransition:YES];
    }];
}

@end
