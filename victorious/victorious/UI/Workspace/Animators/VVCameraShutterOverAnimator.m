//
//  VVCameraShutterOverAnimator.m
//  victorious
//
//  Created by Michael Sena on 1/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVCameraShutterOverAnimator.h"
#import "VCameraViewController.h"

static const NSTimeInterval kBlurOverPresentTransitionDuration = 0.25f;

@implementation VVCameraShutterOverAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return kBlurOverPresentTransitionDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    [[transitionContext containerView] addSubview:toViewController.view];
    
    CGRect finalFrameForToViewController = [transitionContext finalFrameForViewController:toViewController];
    CGFloat largerDimension = MAX(CGRectGetWidth(finalFrameForToViewController), CGRectGetHeight(finalFrameForToViewController));
    UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(finalFrameForToViewController.origin.x, finalFrameForToViewController.origin.y, largerDimension, largerDimension)];
    circleView.center = toViewController.view.center;
    if ([fromViewController isKindOfClass:[VCameraViewController class]])
    {
        VCameraViewController *cameraViewController = (VCameraViewController *)fromViewController;
        circleView.center = [[transitionContext containerView] convertPoint:cameraViewController.shutterCenter fromView:cameraViewController.view];
    }
    circleView.layer.cornerRadius = CGRectGetWidth(circleView.bounds)/2;
    circleView.backgroundColor = [UIColor blackColor];
    circleView.userInteractionEnabled = NO;
    [[transitionContext containerView] addSubview:circleView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         circleView.transform = CGAffineTransformMakeScale(0.00001f, 0.00001f);
     }
                     completion:^(BOOL finished)
     {
         [circleView removeFromSuperview];
         [transitionContext completeTransition:finished];
     }];
}

@end
