//
//  VScaleAnimator.m
//  victorious
//
//  Created by Michael Sena on 7/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VScaleAnimator.h"

@interface VScaleAnimator ()

@property (nonatomic, assign) CGPoint startingCenter;
@property (nonatomic, assign) CGFloat startingScale;

@end

@implementation VScaleAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    if (self.presenting)
    {
        [self calculateStartingScaleAndCenterWithContext:transitionContext];
    }
    
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(self.startingScale, self.startingScale);
    CGPoint finalCenter = [transitionContext containerView].center;
    CGFloat verticalDelta = finalCenter.y - self.startingCenter.y;;
    
    void (^presentingAnimationBlock)(void);
    void (^dismissingAnimationBlock)(void);
    void (^completionBlock)(BOOL finished) = ^void(BOOL finished)
    {
        fromView.alpha = 1.0f;
        fromView.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:YES];
    };
    if (self.presenting)
    {
        [[transitionContext containerView] addSubview:toView];
        toView.transform = CGAffineTransformConcat(scaleTransform, CGAffineTransformMakeTranslation(0, -verticalDelta));
        presentingAnimationBlock = ^void(void)
        {
            toView.transform = CGAffineTransformIdentity;
        };
    }
    else
    {
        dismissingAnimationBlock = ^void(void)
        {
            fromView.transform = CGAffineTransformConcat(scaleTransform, CGAffineTransformMakeTranslation(0, -verticalDelta));
            fromView.alpha = 0.0f;
        };
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.0f
         usingSpringWithDamping:0.8f
          initialSpringVelocity:0.0f
                        options:kNilOptions
                     animations:^
     {
         if (self.presenting)
         {
             presentingAnimationBlock();

         }
         else
         {
             dismissingAnimationBlock();
         }
         
     }
                     completion:completionBlock];
}

- (void)calculateStartingScaleAndCenterWithContext:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *presentingViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    if ([presentingViewController conformsToProtocol:@protocol(VScaleAnimatorSource)])
    {
        id <VScaleAnimatorSource> scaleAnimatorSource = (id<VScaleAnimatorSource>)presentingViewController;
        self.startingCenter = [scaleAnimatorSource startingCenterForAnimator:self inView:[transitionContext containerView]];
        self.startingScale = [scaleAnimatorSource startingScaleForAnimator:self inView:[transitionContext containerView]];
    }
    else
    {
        self.startingCenter = CGPointMake(CGRectGetMidX([transitionContext containerView].bounds),
                                          CGRectGetMidY([transitionContext containerView].bounds));
    }
}

@end
