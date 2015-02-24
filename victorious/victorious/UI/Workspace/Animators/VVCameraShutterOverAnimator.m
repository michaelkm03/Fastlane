//
//  VVCameraShutterOverAnimator.m
//  victorious
//
//  Created by Michael Sena on 1/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VVCameraShutterOverAnimator.h"

// ViewControllers
#import "VCameraViewController.h"
#import "VWorkspaceViewController.h"

// Masking
#import "VRadialGradientView.h"
#import "VRadialGradientLayer.h"
#import "VCanvasView.h"

static const NSTimeInterval kCameraShutterAnimationDuration = 0.55;
static const CGFloat kGradientMagnitude = 20.0f;

@implementation VVCameraShutterOverAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return kCameraShutterAnimationDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    [[transitionContext containerView] addSubview:fromViewController.view];
    [[transitionContext containerView] addSubview:toViewController.view];

    VRadialGradientView *radialGradientMaskView;
    if ([toViewController isKindOfClass:[VWorkspaceViewController class]])
    {
        VWorkspaceViewController *workvc = (VWorkspaceViewController *)toViewController;
        [workvc bringTopChromeOutOfView];
        [workvc bringBottomChromeOutOfView];
        
        radialGradientMaskView = [[VRadialGradientView alloc] initWithFrame:workvc.canvasView.bounds];
        VRadialGradientLayer *radialGradientLayer = radialGradientMaskView.radialGradientLayer;
        radialGradientLayer.colors = @[(id)[UIColor clearColor].CGColor,
                                       (id)[UIColor blackColor].CGColor];
        radialGradientLayer.innerCenter = CGPointMake(CGRectGetMidX(radialGradientLayer.bounds),
                                                      CGRectGetMidY(radialGradientLayer.bounds));
        radialGradientLayer.innerRadius = 0.0f;
        radialGradientLayer.outerCenter = CGPointMake(CGRectGetMidX(radialGradientLayer.bounds),
                                                      CGRectGetMidY(radialGradientLayer.bounds));
        radialGradientLayer.outerRadius = 1.0f;
        radialGradientMaskView.backgroundColor = [UIColor clearColor];
        workvc.view.maskView = radialGradientMaskView;
        [workvc.canvasView addSubview:radialGradientMaskView];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                       {
                           [CATransaction lock];
                           [CATransaction begin];
                           {
                               [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
                               [CATransaction setAnimationDuration:kCameraShutterAnimationDuration];
                               
                               radialGradientLayer.innerRadius = CGRectGetHeight(workvc.canvasView.bounds);
                               radialGradientLayer.outerRadius = CGRectGetHeight(workvc.canvasView.bounds) + kGradientMagnitude;
                           }
                           [CATransaction commit];
                           [CATransaction unlock];
                       });
    }
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.0f
         usingSpringWithDamping:1.0f
          initialSpringVelocity:-1.0f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^
     {
         if ([toViewController isKindOfClass:[VWorkspaceViewController class]])
         {
             VWorkspaceViewController *workspaceVC = (VWorkspaceViewController *)toViewController;
             [workspaceVC bringChromeIntoView];
         }
         if ([fromViewController isKindOfClass:[VCameraViewController class]])
         {
             VCameraViewController *cameraVC = (VCameraViewController *)fromViewController;
             [cameraVC setToolbarHidden:self.presenting];
         }
         if ([toViewController isKindOfClass:[VCameraViewController class]])
         {
             VCameraViewController *cameraVC = (VCameraViewController *)toViewController;
             [cameraVC setToolbarHidden:self.presenting];
         }
     }
                     completion:^(BOOL finished)
    {
        [transitionContext completeTransition:YES];
    }];
}

@end
