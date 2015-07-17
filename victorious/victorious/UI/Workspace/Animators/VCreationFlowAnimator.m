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
    if (self.presenting)
    {
        toView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight([transitionContext containerView].bounds));
    }
    else
    {
        toView.transform = CGAffineTransformMakeScale(kScaleFactor, kScaleFactor);
        toView.alpha = kDimmedAlpha;
        [[transitionContext containerView] addSubview:fromView];
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
             fromView.transform = CGAffineTransformMakeScale(kScaleFactor, kScaleFactor);
             fromView.alpha = kDimmedAlpha;
         }
         else
         {
             fromView.transform = CGAffineTransformMakeTranslation(0, CGRectGetHeight([transitionContext containerView].bounds));
             toView.transform = CGAffineTransformIdentity;
             toView.alpha = 1.0f;
         }
     }
                     completion:^(BOOL finished)
     {
         [transitionContext completeTransition:YES];
     }];
}

@end
