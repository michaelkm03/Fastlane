//
//  VFromTopViewControllerAnimator.m
//  victorious
//
//  Created by Michael Sena on 7/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VFromTopViewControllerAnimator.h"

@implementation VFromTopViewControllerAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    if (self.presenting)
    {
        [[transitionContext containerView] addSubview:toView];
        toView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight([transitionContext containerView].bounds));
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
         }
         else
         {
             fromView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight([transitionContext containerView].bounds));
         }
         
     }
                     completion:^(BOOL finished)
     {
         [transitionContext completeTransition:YES];
     }];
}

@end
