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
    return 5.0f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)context
{
    UIViewController* toVC = (VContentInfoViewController*)[context viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromVC = (VContentViewController*)[context viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    [[context containerView] insertSubview:toVC.view belowSubview:fromVC.view];
    
    if (self.movingChildVC)
    {
        CGRect childFrameInSuperview = [[context containerView] convertRect:self.fromChildContainerView.frame fromView:self.fromChildContainerView.superview];
        self.fromChildContainerView.frame = childFrameInSuperview;

        [self.fromChildContainerView removeFromSuperview];
        [[context containerView] addSubview:self.fromChildContainerView];
        [toVC addChildViewController:self.movingChildVC];
        [self.movingChildVC didMoveToParentViewController:toVC];
    }
    
    CGFloat duration = [self transitionDuration:context];
    
    [UIView animateWithDuration:duration/4
                     animations:
     ^{
         self.fromChildContainerView.transform = CGAffineTransformScale(self.fromChildContainerView.transform, 1.1, 1.1);
     }
                     completion:^(BOOL finished)
     {
         fromVC.view.alpha = 0;
         [UIView transitionFromView:fromVC.view
                             toView:toVC.view
                           duration:duration/2
                            options:self.isPresenting ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight
                         completion:
          ^(BOOL finished){
              
              [UIView animateWithDuration:duration/4
                               animations:
               ^{
                   self.movingChildVC.view.frame = [[context containerView] convertRect:self.toChildContainerView.frame fromView:toVC.view];
               }
                               completion:
               ^(BOOL finished) {
                   [self.toChildContainerView addSubview:self.movingChildVC.view];
                   self.movingChildVC.view.frame = self.toChildContainerView.bounds;
                   [context completeTransition:![context transitionWasCancelled]];
               }];
          }];
     }];
}

@end
