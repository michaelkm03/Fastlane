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
    
    if (self.movingImage)
    {
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.toChildContainerView.bounds];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.toChildContainerView addSubview:imageView];
        [imageView setImage:[self.movingImage resizableImageWithCapInsets:UIEdgeInsetsZero]];
    }
    
    [UIView transitionFromView:fromSnapshot
                        toView:toVC.view
                      duration:[self transitionDuration:context]
                       options:!self.isPresenting ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight
                    completion:^(BOOL finished)
    {
        [context completeTransition:![context transitionWasCancelled]];
    }];
}

@end
