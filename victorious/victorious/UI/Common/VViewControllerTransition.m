//
//  VViewControllerTransition.m
//  victorious
//
//  Created by Patrick Lynch on 12/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VViewControllerTransition.h"
#import "UIViewController+RenderToImageView.h"
#import "VAnimatedTransitionViewController.h"

@implementation VViewControllerTransitionAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 2.0f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    const BOOL isPresenting = [toViewController presentedViewController] != fromViewController;
    
    UIImageView *imageView = nil;
    id<VAnimatedTransitionViewController> animateableViewController = nil;
    
    if ( [toViewController conformsToProtocol:@protocol(VAnimatedTransitionViewController) ] )
    {
        animateableViewController = (id<VAnimatedTransitionViewController>)toViewController;
        
        if ( [animateableViewController requiresImageViewFromOriginViewController] )
        {
            //imageView = [fromViewController rederedAsImageView];
        }
    }
    
    if ( isPresenting )
    {
        toViewController.view.frame = fromViewController.view.frame;
        
        fromViewController.view.userInteractionEnabled = NO;
        
        [transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];
        
        /*if ( animateableViewController != nil )
        {
            [animateableViewController prepareForTransitionIn:imageView];
            [animateableViewController performTransitionIn:[self transitionDuration:transitionContext]];
        }*/
        
        [transitionContext completeTransition:YES];
    }
    else
    {
        fromViewController.view.userInteractionEnabled = YES;
        
        [transitionContext.containerView addSubview:toViewController.view];
        [transitionContext.containerView addSubview:fromViewController.view];
        
        /*if ( animateableViewController != nil )
        {
            [animateableViewController prepareForTransitionOut:imageView];
            [animateableViewController performTransitionOut:[self transitionDuration:transitionContext]];
        }*/
        
        [transitionContext completeTransition:YES];
    }
}

@end

@interface VViewControllerTransition()

@property (nonatomic, strong) id<UIViewControllerAnimatedTransitioning> animator;

@end

@implementation VViewControllerTransition

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source
{
    return [[VViewControllerTransitionAnimator alloc] init];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[VViewControllerTransitionAnimator alloc] init];
}

@end
