//
//  VActionSheetPresentationAnimator.m
//  victorious
//
//  Created by Michael Sena on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VActionSheetPresentationAnimator.h"

#import "VActionSheetViewController.h"

@interface VActionSheetPresentationAnimator ()

@property (nonatomic, strong) UIView *dimmingView;

@end

@implementation VActionSheetPresentationAnimator

static const NSTimeInterval kPresentationDuration = 0.35f;
static const NSTimeInterval kDismissalDuration = 0.45f;
static const CGFloat kDimmingViewAlpha = 0.5f;
static const CGFloat kSpringDampingConstant = 0.88f;
static const CGFloat kAvatarAnimationTranfromYTranlation = 100.0f;
static const CGFloat kAnticipationYTranslation = 8.0f;
static const CGFloat kAnticipationAnimationDurationPercentage = 1.0f/3.0f;
static const CGFloat kDismissalAnimationDurationPercentage = 1.0f - kAnticipationAnimationDurationPercentage;
static const CGFloat kDimmingViewTag = 12241989;

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    if (self.isPresenting)
    {
        return kPresentationDuration;
    }
    return kDismissalDuration;
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
        
        [[transitionContext containerView] addSubview:self.dimmingView];
        [[transitionContext containerView] addSubview:toViewController.view];
        
        toViewController.view.frame = CGRectMake(CGRectGetMinX(fromViewController.view.frame),
                                                 CGRectGetHeight(fromViewController.view.frame),
                                                 CGRectGetWidth(fromViewController.view.frame),
                                                 CGRectGetHeight(fromViewController.view.frame));
        
        if ([toViewController isKindOfClass:[VActionSheetViewController class]])
        {
            VActionSheetViewController *actionSheetViewController = (VActionSheetViewController *)toViewController;
            actionSheetViewController.view.frame = CGRectMake(CGRectGetMinX(fromViewController.view.frame),
                                                              CGRectGetHeight(fromViewController.view.frame) + actionSheetViewController.totalHeight,
                                                              CGRectGetWidth(fromViewController.view.frame),
                                                              CGRectGetHeight(fromViewController.view.frame));
            
            actionSheetViewController.avatarView.transform = CGAffineTransformMakeTranslation(0, kAvatarAnimationTranfromYTranlation );
        }
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                              delay:0.0f
             usingSpringWithDamping:kSpringDampingConstant
              initialSpringVelocity:0.0f
                            options:kNilOptions
                         animations:^
         {
             toViewController.view.frame = fromViewController.view.bounds;
             self.dimmingView.alpha = 1.0f;
             self.dimmingView.tag = kDimmingViewTag;
             if ([toViewController isKindOfClass:[VActionSheetViewController class]])
             {
                 VActionSheetViewController *actionSheetViewController = (VActionSheetViewController *)toViewController;
                 actionSheetViewController.avatarView.transform = CGAffineTransformIdentity;
             }
         }
                         completion:^(BOOL finished)
         {
             [transitionContext completeTransition:YES];
         }];
    }
    else
    {
        toViewController.view.userInteractionEnabled = YES;
        fromViewController.view.userInteractionEnabled = NO;
        
        self.dimmingView = [[transitionContext containerView] viewWithTag:kDimmingViewTag];

        [transitionContext containerView].userInteractionEnabled = NO;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] * kAnticipationAnimationDurationPercentage
                              delay:0.0f
             usingSpringWithDamping:kSpringDampingConstant
              initialSpringVelocity:0.0f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^
        {
            fromViewController.view.frame = CGRectMake(CGRectGetMinX(fromViewController.view.frame),
                                                       CGRectGetMinY(fromViewController.view.frame) - kAnticipationYTranslation,
                                                       CGRectGetWidth(fromViewController.view.frame),
                                                       CGRectGetHeight(fromViewController.view.frame));
        }
                         completion:^(BOOL finished)
         {
             [UIView animateWithDuration:[self transitionDuration:transitionContext] * kDismissalAnimationDurationPercentage
                                   delay:0.0f
                  usingSpringWithDamping:kSpringDampingConstant
                   initialSpringVelocity:0.0f
                                 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                              animations:^
              {
                  self.dimmingView.alpha = 0.0f;
                  
                  if ([fromViewController isKindOfClass:[VActionSheetViewController class]])
                  {
                      VActionSheetViewController *actionSheetViewController = (VActionSheetViewController *)fromViewController;
                      actionSheetViewController.avatarView.transform = CGAffineTransformMakeTranslation(0, -kAvatarAnimationTranfromYTranlation);
                      actionSheetViewController.view.frame = CGRectMake(CGRectGetMinX(fromViewController.view.frame),
                                                                        CGRectGetHeight(fromViewController.view.frame) + actionSheetViewController.totalHeight,
                                                                        CGRectGetWidth(fromViewController.view.frame),
                                                                        CGRectGetHeight(fromViewController.view.frame));
                  }
              }
                              completion:^(BOOL finished)
              {
                  [transitionContext completeTransition:YES];
              }];
         }];
    }
}

@end
