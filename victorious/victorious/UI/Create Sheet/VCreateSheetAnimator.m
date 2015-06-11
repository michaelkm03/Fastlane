//
//  VCreateSheetAnimator.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 6/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCreateSheetAnimator.h"
#import "VCreateSheetPresentationController.h"
#import "VCreateSheetViewController.h"

static const CGFloat kPresentTotalTime = 0.6f;
static const CGFloat kPresentDelay = 0.1f;
static const CGFloat kDismissTotalTime = 0.4f;

@implementation VCreateSheetAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return [self isPresentation] ? kPresentTotalTime : kDismissTotalTime;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    BOOL isPresentation = [self isPresentation];
    
    CGAffineTransform transitionDownTransform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(fromViewController.view.bounds));
    CGAffineTransform scaleUpTransform = CGAffineTransformMakeScale(1.0f, 0.0f);
    
    VCreateSheetViewController *animatingViewController = isPresentation ? (VCreateSheetViewController *)toViewController : (VCreateSheetViewController *)fromViewController;
    
    if (isPresentation)
    {
        UIView *animatingView = animatingViewController.collectionView;
        
        animatingView.alpha = 0.0f;
//        animatingView.transform = CGAffineTransformConcat(transitionDownTransform, scaleUpTransform);
        animatingView.transform = scaleUpTransform;
        [containerView addSubview:animatingViewController.view];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] - kPresentDelay
                              delay:kPresentDelay
             usingSpringWithDamping:0.7f
              initialSpringVelocity:0.0f
                            options:0
                         animations:^
         {
             animatingView.transform = CGAffineTransformIdentity;
             animatingView.alpha = 1.0f;
         } completion:^(BOOL finished)
         {
             [transitionContext completeTransition:YES];
         }];
        
        UIButton *dismissButton = animatingViewController.dismissButton;
        
        dismissButton.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight(dismissButton.bounds));
        
        [UIView animateKeyframesWithDuration:0.3 delay:0 options:0 animations:^
        {
            dismissButton.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
    else
    {
        UIView *animatingView = animatingViewController.view;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.0f
             usingSpringWithDamping:0.75f
              initialSpringVelocity:0.0f
                            options:0
                         animations:^
         {
             animatingView.transform = transitionDownTransform;
             animatingView.alpha = 0.0f;
         } completion:^(BOOL finished)
         {
             [transitionContext completeTransition:YES];
         }];
    }
}

@end

@interface VCreateSheetTransitionDelegate ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VCreateSheetTransitionDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source
{
    VCreateSheetAnimator *animatedTransitioner = [[VCreateSheetAnimator alloc] init];
    animatedTransitioner.presentation = YES;
    return animatedTransitioner;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    VCreateSheetAnimator *animatedTransitioner = [[VCreateSheetAnimator alloc] init];
    animatedTransitioner.presentation = NO;
    return animatedTransitioner;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                      presentingViewController:(UIViewController *)presenting
                                                          sourceViewController:(UIViewController *)source
{
    VCreateSheetPresentationController *presentationController = [[VCreateSheetPresentationController alloc] initWithPresentedViewController:presented
                                                                                                                    presentingViewController:presenting
                                                                                                                                      source:source];
    [presentationController setDependencyManager:self.dependencyManager];
    return presentationController;
}

@end
