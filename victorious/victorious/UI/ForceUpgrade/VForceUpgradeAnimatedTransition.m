//
//  VForceUpgradeAnimatedTransition.m
//  victorious
//
//  Created by Josh Hinman on 6/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIImage+ImageEffects.h"
#import "VForceUpgradeAnimatedTransition.h"

@interface VForceUpgradeAnimatedTransition () <UIDynamicAnimatorDelegate>

@property (nonatomic, strong) UIDynamicAnimator                        *animator;
@property (nonatomic, strong) id<UIViewControllerContextTransitioning>  transitionContext;

@end

@implementation VForceUpgradeAnimatedTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *inView = [transitionContext containerView];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = [[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey] view];

    UIView *normalSnapshot = [fromView snapshotViewAfterScreenUpdates:YES];
    [inView addSubview:normalSnapshot];
    [fromView removeFromSuperview];
    
    UIImage *blurredSnapshot = [self blurredSnapshotOfView:fromView];
    
    UIImageView *blurredImageView = [[UIImageView alloc] initWithImage:blurredSnapshot];
    blurredImageView.frame = inView.bounds;
    blurredImageView.alpha = 0;
    [inView addSubview:blurredImageView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                     animations:^(void)
    {
        blurredImageView.alpha = 1.0f;
        normalSnapshot.alpha = 0;
    }
                     completion:^(BOOL finished)
    {
        [normalSnapshot removeFromSuperview];
    }];
    
    CGRect frame = [transitionContext finalFrameForViewController:toViewController];
    toViewController.view.frame = CGRectMake(0.0f, -CGRectGetHeight(frame) + 20.0f, CGRectGetWidth(frame), CGRectGetHeight(frame));
    [inView addSubview:toViewController.view];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:inView];
    self.animator.delegate = self;
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[toViewController.view]];
    gravity.magnitude = 1.5;
    
    UIDynamicItemBehavior *elasticity = [[UIDynamicItemBehavior alloc] initWithItems:@[toViewController.view]];
    elasticity.elasticity = 0.1f;

    UICollisionBehavior *collision = [[UICollisionBehavior alloc] initWithItems:@[toViewController.view]];
    [collision addBoundaryWithIdentifier:@"bottom"
                               fromPoint:CGPointMake(CGRectGetMinX(inView.bounds), CGRectGetMaxY(inView.bounds))
                                 toPoint:CGPointMake(CGRectGetMaxX(inView.bounds), CGRectGetMaxY(inView.bounds))];
    
    [self.animator addBehavior:gravity];
    [self.animator addBehavior:elasticity];
    [self.animator addBehavior:collision];
    
    self.transitionContext = transitionContext;
}

- (UIImage *)blurredSnapshotOfView:(UIView *)view
{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [image applyDarkEffect];
}

#pragma mark - UIDynamicAnimatorDelegate methods

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator
{
    [self.transitionContext completeTransition:YES];
}

@end
