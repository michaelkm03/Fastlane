//
//  VViewControllerTransition.m
//  victorious
//
//  Created by Patrick Lynch on 12/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VViewControllerTransition.h"

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

@interface VViewControllerTransition ()

@property (nonatomic, strong) id<VAnimatedTransition> transition;

@end

@implementation VViewControllerTransition

- (instancetype)initWithTransition:(id<VAnimatedTransition>)transition
{
    self = [super init];
    if (self)
    {
        _transition = transition;
    }
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source
{
    return [[VViewControllerTransitionAnimator alloc] initWithTransition:self.transition];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[VViewControllerTransitionAnimator alloc] initWithTransition:self.transition];
}

@end
