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
        self.referenceView = referenceView;
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
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
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
    
    UIImage *blurredSnapshot = [self blurredSnapshotOfView:fromViewController.view];
    toViewController.backgroundView = [[UIImageView alloc] initWithImage:blurredSnapshot];
    
    if (toView)
    {
        toView.frame = [transitionContext finalFrameForViewController:toViewController];
        [inView addSubview:toView];
        [toView layoutIfNeeded];
    }
    
    CGRect frameForContentView = toViewController.contentView.frame;
    toViewController.backgroundView.alpha = 0;
    toViewController.contentView.frame = [toViewController.contentSuperview convertRect:self.referenceView.frame fromView:self.referenceView.superview];
    
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

- (void)setReferenceView:(UIView *)referenceView
{
    _referenceView = referenceView;
}

- (UIImage *)blurredSnapshotOfView:(UIView *)view
{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image applyDarkEffect];
}

@end
