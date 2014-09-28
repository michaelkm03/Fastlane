//
//  VActionSheetPresentationAnimator.m
//  victorious
//
//  Created by Michael Sena on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VActionSheetPresentationAnimator.h"

@interface VActionSheetPresentationAnimator ()

@property (nonatomic, strong) UIView *dimmingView;

@end

@implementation VActionSheetPresentationAnimator

static const NSTimeInterval kPresentationDuration = 0.55f;
static const CGFloat kDimmingViewAlpha = 0.5f;
static const CGFloat kSpringDampingConstant = 0.8f;

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return kPresentationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (self.presenting)
    {
        fromViewController.view.userInteractionEnabled = NO;
        
        self.dimmingView = [[UIView alloc] initWithFrame:[transitionContext containerView].bounds];
        self.dimmingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:kDimmingViewAlpha];
        self.dimmingView.alpha = 0.0f;
        
        [[transitionContext containerView] addSubview:fromViewController.view];
        [[transitionContext containerView] addSubview:self.dimmingView];
        [[transitionContext containerView] addSubview:toViewController.view];
        
        toViewController.view.frame = CGRectMake(0,
                                                 CGRectGetHeight(fromViewController.view.frame),
                                                 CGRectGetWidth(fromViewController.view.frame),
                                                 CGRectGetHeight(fromViewController.view.frame));
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.0f
             usingSpringWithDamping:kSpringDampingConstant
              initialSpringVelocity:0.0f
                            options:kNilOptions
                         animations:^
         {
             toViewController.view.frame = fromViewController.view.bounds;
             self.dimmingView.alpha = 1.0f;
         }
                         completion:^(BOOL finished)
         {
             [transitionContext completeTransition:YES];
         }];
    }
    else
    {
        toViewController.view.userInteractionEnabled = YES;
        
        [[transitionContext containerView] addSubview:toViewController.view];
        [[transitionContext containerView] addSubview:fromViewController.view];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.0f
             usingSpringWithDamping:kSpringDampingConstant
              initialSpringVelocity:0.0f
                            options:kNilOptions
                         animations:^
         {
             fromViewController.view.frame = CGRectMake(CGRectGetMinX([transitionContext containerView].bounds),
                                                        CGRectGetHeight([transitionContext containerView].bounds),
                                                        CGRectGetWidth([transitionContext containerView].bounds),
                                                        CGRectGetHeight([transitionContext containerView].bounds));
             self.dimmingView.alpha = 0.0f;
         }
                         completion:^(BOOL finished)
         {
             [transitionContext completeTransition:YES];
         }];
    }
}

@end
