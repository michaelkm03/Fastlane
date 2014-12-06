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
    
    const BOOL isUnwinding = [toViewController presentedViewController] == fromViewController;
    const BOOL isPresenting = !isUnwinding;
    
    UIImageView *imageView = nil;
    id<VAnimatedTransitionViewController> animateableViewController = nil;
    
    if ( [toViewController conformsToProtocol:@protocol(VAnimatedTransitionViewController) ] )
    {
        animateableViewController = (id<VAnimatedTransitionViewController>)toViewController;
        
        if ( [animateableViewController requiresImageViewFromOriginViewController] )
        {
            imageView = [fromViewController rederedAsImageView];
        }
    }
    
    if ( isPresenting )
    {
        toViewController.view.frame = fromViewController.view.frame;
        
        [transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];
        
        if ( animateableViewController != nil )
        {
            [animateableViewController prepareForTransitionIn:imageView];
            [animateableViewController performTransitionIn:[self transitionDuration:transitionContext]];
        }
        
    }
    else
    {
        [transitionContext.containerView addSubview:toViewController.view];
        [transitionContext.containerView addSubview:fromViewController.view];
        
        if ( animateableViewController != nil )
        {
            [animateableViewController prepareForTransitionOut:imageView];
            [animateableViewController performTransitionOut:[self transitionDuration:transitionContext]];
        }
        
    }
}

- (void)animationEnded:(BOOL)transitionCompleted
{
    
}

@end

@interface VViewControllerTransition()

@property (nonatomic, strong) id<UIViewControllerAnimatedTransitioning> animator;

@end

@implementation VViewControllerTransition

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.animator = [[VViewControllerTransitionAnimator alloc] init];
    }
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source
{
    return self.animator;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self.animator;
}

@end
