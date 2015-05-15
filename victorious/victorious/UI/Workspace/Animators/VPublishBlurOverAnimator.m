//
//  VPublishBlurOverAnimator.m
//  victorious
//
//  Created by Michael Sena on 12/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPublishBlurOverAnimator.h"
#import "UIImageView+Blurring.h"

#import "VPublishViewController.h"

static const NSTimeInterval kBlurOverPresentTransitionDuration = 0.75f;
static const NSTimeInterval kBlurOverDismissTransitionDuration = 0.5f;

@interface VPublishBlurOverAnimator ()

@property (nonatomic, strong) UIImageView *blurredImageView;

@end

@implementation VPublishBlurOverAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return self.presenting ? kBlurOverPresentTransitionDuration : kBlurOverDismissTransitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    if (self.presenting)
    {
        UIView *snapshot = fromViewController.view;
        UIGraphicsBeginImageContextWithOptions(snapshot.bounds.size, YES, 0.0f);
        [snapshot.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.blurredImageView = [[UIImageView alloc] initWithFrame:[transitionContext containerView].bounds];
        [toViewController.view addSubview:self.blurredImageView];
        [toViewController.view sendSubviewToBack:self.blurredImageView];
        
        [[transitionContext containerView] addSubview:toViewController.view];
        toViewController.view.alpha = 0.0f;
        
        [self.blurredImageView blurImage:snapshotImage withTintColor:nil toCallbackBlock:^(UIImage *blurredImage)
        {
            self.blurredImageView.image = blurredImage;
            [self animateToNewViewControllerWithContext:transitionContext];
        }];
    }
    else
    {
        [[transitionContext containerView] addSubview:toViewController.view];
        [[transitionContext containerView] sendSubviewToBack:toViewController.view];
        [self animateToNewViewControllerWithContext:transitionContext];
    }
}

- (void)animateToNewViewControllerWithContext:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.0f
         usingSpringWithDamping:0.7f
          initialSpringVelocity:0.0f
                        options:kNilOptions
                     animations:^
     {
         if (self.presenting)
         {
             if ([toViewController isKindOfClass:[VPublishViewController class]])
             {
                 VPublishViewController *publishVC = (VPublishViewController *)toViewController;
                 publishVC.animateInBlock();
             }
             toViewController.view.alpha = 1.0f;
         }
         else
         {
             fromViewController.view.alpha = 0.0f;
             self.blurredImageView.alpha = 0.0f;
         }
     }
                     completion:^(BOOL finished)
     {
         if (!self.presenting)
         {
             [self.blurredImageView removeFromSuperview];
         }
         
         [transitionContext completeTransition:finished];
     }];
}

@end
