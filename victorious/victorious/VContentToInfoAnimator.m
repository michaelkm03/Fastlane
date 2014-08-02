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
    
    if (self.movingImage)
    {
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:self.toChildContainerView.bounds];
        
        UIGraphicsBeginImageContext(imageView.frame.size);
        [self.movingImage drawInRect:CGRectMake(0,0,imageView.frame.size.width,imageView.frame.size.height)];
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    
        [imageView setImage:newImage];
        [self.toChildContainerView addSubview:imageView];
    }

    [[context containerView] addSubview:toVC.view];
    [toVC.view layoutSubviews];
    
    [[context containerView] addSubview:fromSnapshot];
    
    //TODO: unhacky this
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [UIView transitionFromView:fromSnapshot
                            toView:toVC.view
                          duration:[self transitionDuration:context]
                           options:!self.isPresenting ? UIViewAnimationOptionTransitionFlipFromLeft : UIViewAnimationOptionTransitionFlipFromRight
                        completion:^(BOOL finished)
         {
             [context completeTransition:![context transitionWasCancelled]];
         }];
    });
}

@end
