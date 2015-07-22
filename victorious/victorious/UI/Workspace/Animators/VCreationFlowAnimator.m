//
//  VCreationFlowAnimator.m
//  victorious
//
//  Created by Michael Sena on 7/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCreationFlowAnimator.h"

#import "VCreationFlowController.h"

static const CGFloat kScaleFactor = 0.8f;
static const CGFloat kDimmedAlpha = 0.5f;

@implementation VCreationFlowAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.8f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    [[transitionContext containerView] addSubview:toView];
    [[transitionContext containerView] addSubview:fromView];
    if (self.presenting)
    {
        toView.transform = CGAffineTransformMakeScale(kScaleFactor, kScaleFactor);
        toView.alpha = kDimmedAlpha;
    }
    else
    {
        toView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight([transitionContext containerView].bounds));
        [[transitionContext containerView] addSubview:toView];
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.0f
         usingSpringWithDamping:0.8f
          initialSpringVelocity:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^
     {
         if (self.presenting)
         {
             toView.transform = CGAffineTransformIdentity;
             toView.alpha = 1.0f;
             fromView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight([transitionContext containerView].bounds));
         }
         else
         {
             fromView.transform = CGAffineTransformMakeScale(kScaleFactor, kScaleFactor);
             fromView.alpha = kDimmedAlpha;
             toView.transform = CGAffineTransformIdentity;
         }
     }
                     completion:^(BOOL finished)
     {
         toView.transform = CGAffineTransformIdentity;
         fromView.transform = CGAffineTransformIdentity;
         toView.alpha = 1.0f;
         fromView.alpha = 1.0f;
         [transitionContext completeTransition:YES];
     }];
}

@end
