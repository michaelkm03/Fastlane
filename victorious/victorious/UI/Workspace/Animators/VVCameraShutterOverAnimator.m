//
//  VVCameraShutterOverAnimator.m
//  victorious
//
//  Created by Michael Sena on 1/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVCameraShutterOverAnimator.h"


static const NSTimeInterval kBlurOverPresentTransitionDuration = 0.75f;

@implementation VVCameraShutterOverAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return kBlurOverPresentTransitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [[transitionContext containerView] addSubview:fromViewController.view];
    [[transitionContext containerView] addSubview:toViewController.view];
//    [[transitionContext containerView] sendSubviewToBack:toViewController.view];
    
    UIView *circleView = [[UIView alloc] initWithFrame:CGRectInset([transitionContext containerView].bounds, -CGRectGetWidth([transitionContext containerView].bounds), -CGRectGetWidth([transitionContext containerView].bounds))];
    circleView.layer.cornerRadius = CGRectGetWidth(circleView.bounds)/2;
    circleView.backgroundColor = [UIColor blackColor];
    [[transitionContext containerView] addSubview:circleView];
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.0f
         usingSpringWithDamping:0.7f
          initialSpringVelocity:0.0f
                        options:kNilOptions
                     animations:^
     {
         circleView.backgroundColor = [UIColor blueColor];
         circleView.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
     }
                     completion:^(BOOL finished)
     {
         [transitionContext completeTransition:finished];
     }];
}

@end
