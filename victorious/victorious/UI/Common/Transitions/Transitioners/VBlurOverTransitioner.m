//
//  VBlurOverTransitioner.m
//  victorious
//
//  Created by Michael Sena on 3/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBlurOverTransitioner.h"

#import "VBlurOverPresentationController.h"

static const CGFloat kTransitionScaleFactor = 1.2f;

@implementation VBlurOverAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5f;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *fromView = [fromVC view];
    UIViewController *toVC   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = [toVC view];
    
    UIView *containerView = [transitionContext containerView];
    
    BOOL isPresentation = [self isPresentation];
    
    if (isPresentation)
    {
        [containerView addSubview:toView];
    }
    
    UIViewController *animatingVC = isPresentation? toVC : fromVC;
    UIView *animatingView = [animatingVC view];
    
    [animatingView setFrame:[transitionContext finalFrameForViewController:animatingVC]];
    
    animatingView.transform = isPresentation ? CGAffineTransformMakeScale(kTransitionScaleFactor, kTransitionScaleFactor) : CGAffineTransformMakeScale(1, 1);
    CGAffineTransform finalTransform = isPresentation ? CGAffineTransformIdentity : CGAffineTransformMakeScale(kTransitionScaleFactor, kTransitionScaleFactor);
    animatingView.alpha = isPresentation ? 0.0f : 1.0f;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
         usingSpringWithDamping:0.9f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                     animations:^
     {
         animatingView.transform = finalTransform;
         animatingView.alpha = isPresentation ? 1.0f : 0.0f;
     }
                     completion:^(BOOL finished)
     {
         if (![self isPresentation])
         {
             [fromView removeFromSuperview];
         }
         [transitionContext completeTransition:YES];
     }];

}

@end

@implementation VBlurOverTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source
{
    VBlurOverAnimatedTransitioning *animatedTransitioner = [[VBlurOverAnimatedTransitioning alloc] init];
    animatedTransitioner.presentation = YES;
    return animatedTransitioner;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[VBlurOverAnimatedTransitioning alloc] init];
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    return [[VBlurOverPresentationController alloc] initWithPresentedViewController:presented
                                                           presentingViewController:presenting];
}

@end
