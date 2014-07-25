//
//  VContentToInfoAnimator.m
//  victorious
//
//  Created by Will Long on 7/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentToInfoAnimator.h"

#import "VContentInfoViewController.h"

#import "VContentViewController.h"
#import "VContentViewController+Videos.h"

@implementation VContentToInfoAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 1.0f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)context
{
    UIViewController* toVC = (VContentInfoViewController*)[context viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromVC = (VContentViewController*)[context viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView* fromSnapshot = [fromVC.view resizableSnapshotViewFromRect:fromVC.view.bounds
                                                   afterScreenUpdates:NO
                                                        withCapInsets:UIEdgeInsetsZero];
    
    [[context containerView] addSubview:toVC.view];
    [[context containerView] addSubview:fromSnapshot];
    
    if (self.movingChildVC)
    {
        
        self.movingChildVC.view.frame = self.toChildContainerView.bounds;
        [self.toChildContainerView addSubview:self.movingChildVC.view];
        [self.movingChildVC willMoveToParentViewController:toVC];
        [toVC addChildViewController:self.movingChildVC];
        [self.movingChildVC didMoveToParentViewController:toVC];
    }
    else if (self.movingImage)
    {
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.toChildContainerView.bounds];
        imageView.image = [self.movingImage resizableImageWithCapInsets:UIEdgeInsetsZero];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.toChildContainerView addSubview:imageView];
    }
    
    UIView* toSnapshot = [toVC.view resizableSnapshotViewFromRect:toVC.view.bounds
                                                 afterScreenUpdates:NO
                                                      withCapInsets:UIEdgeInsetsZero];
    [[context containerView] insertSubview:toSnapshot belowSubview:fromSnapshot];

    [UIView transitionFromView:fromSnapshot
                        toView:toSnapshot
                      duration:[self transitionDuration:context]
                       options:self.isPresenting ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight
                    completion:^(BOOL finished)
    {
        [context completeTransition:![context transitionWasCancelled]];
    }];
}

@end
