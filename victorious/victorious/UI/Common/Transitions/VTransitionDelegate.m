//
//  VViewControllerTransition.m
//  victorious
//
//  Created by Patrick Lynch on 12/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTransitionDelegate.h"

@interface VViewControllerTransitionAnimator ()

@property (nonatomic, strong) id<VAnimatedTransition> transition;

@end

@implementation VViewControllerTransitionAnimator

- (instancetype)initWithTransition:(id<VAnimatedTransition>)transition
{
    self = [super init];
    if (self)
    {
        _transition = transition;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    VTransitionModel *model = [[VTransitionModel alloc] initWithTransitionContext:transitionContext transition:self.transition];
    
    return model.animationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    VTransitionModel *model = [[VTransitionModel alloc] initWithTransitionContext:transitionContext transition:self.transition];
    
    if ( model.isPresenting )
    {
        model.toViewController.view.frame = model.fromViewController.view.frame;
        
        [transitionContext.containerView addSubview:model.fromViewController.view];
        [transitionContext.containerView addSubview:model.toViewController.view];
        
        [self.transition prepareForTransitionIn:model];
        [self.transition performTransitionIn:model completion:^(BOOL didComplete)
        {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
    else
    {
        model.fromViewController.view.frame = model.toViewController.view.frame;
        
        [transitionContext.containerView addSubview:model.toViewController.view];
        [transitionContext.containerView addSubview:model.fromViewController.view];
        
        [self.transition prepareForTransitionOut:model];
        [self.transition performTransitionOut:model completion:^(BOOL didComplete)
         {
             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
         }];
    }
}

@end

@interface VTransitionDelegate ()

@property (nonatomic, strong) id<VAnimatedTransition> transition;
@property (nonatomic, strong) VViewControllerTransitionAnimator *animator;

@end

@implementation VTransitionDelegate

- (instancetype)initWithTransition:(id<VAnimatedTransition>)transition
{
    self = [super init];
    if (self)
    {
        _transition = transition;
        _animator = [[VViewControllerTransitionAnimator alloc] initWithTransition:self.transition];
    }
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source
{
    if ( [self.transition respondsToSelector:@selector(canPerformCustomTransitionFrom:to:)] )
    {
        if ( ![self.transition canPerformCustomTransitionFrom:presented to:presenting] )
        {
            return nil;
        }
    }
    return self.animator;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    if ( [self.transition respondsToSelector:@selector(canPerformCustomTransitionFrom:to:)] )
    {
        if ( ![self.transition canPerformCustomTransitionFrom:nil to:dismissed] )
        {
            return nil;
        }
    }
    return self.animator;
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    if ( [self.transition respondsToSelector:@selector(canPerformCustomTransitionFrom:to:)] )
    {
        if ( ![self.transition canPerformCustomTransitionFrom:fromVC to:toVC] )
        {
            return nil;
        }
    }
    return self.animator;
}

@end
