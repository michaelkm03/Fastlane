//
//  VViewControllerTransition.m
//  victorious
//
//  Created by Patrick Lynch on 12/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VViewControllerTransition.h"
#import "UIViewController+RenderToImageView.h"

@interface VViewControllerTransitionModel : NSObject

@property (nonatomic, readonly, strong) UIViewController *fromViewController;
@property (nonatomic, readonly, strong) UIViewController *toViewController;
@property (nonatomic, readonly, strong) UIImageView *fromImageView;
@property (nonatomic, readonly, strong) id<VAnimatedTransitionViewController> animatedTranstionViewController;
@property (nonatomic, readonly, assign) NSTimeInterval animationDuration;
@property (nonatomic, readonly, assign) BOOL isPresenting;

@end


@implementation VViewControllerTransitionModel

- (instancetype)initWithTransitionContext:(id <UIViewControllerContextTransitioning>)transitionContext
{
    self = [super init];
    if (self)
    {
        _fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        _toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        _isPresenting = [_toViewController presentedViewController] != _fromViewController;
        
        UIViewController *targetVc = _isPresenting ? _toViewController : _fromViewController;
        
        if ( [targetVc conformsToProtocol:@protocol(VAnimatedTransitionViewController) ] )
        {
            _animatedTranstionViewController = (id<VAnimatedTransitionViewController>)targetVc;
            _animationDuration = _isPresenting ? _animatedTranstionViewController.transitionInDuration : _animatedTranstionViewController.transitionOutDuration;
            if ( [self.animatedTranstionViewController requiresImageViewFromOriginViewController] )
            {
                _fromImageView = [_fromViewController rederedAsImageView];
            }
        }
    }
    return self;
}

@end

@implementation VViewControllerTransitionAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    VViewControllerTransitionModel *model = [[VViewControllerTransitionModel alloc] initWithTransitionContext:transitionContext];
    
    return model.animationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    VViewControllerTransitionModel *model = [[VViewControllerTransitionModel alloc] initWithTransitionContext:transitionContext];
    
    if ( model.isPresenting )
    {
        model.toViewController.view.frame = model.fromViewController.view.frame;
        
        [transitionContext.containerView addSubview:model.fromViewController.view];
        [transitionContext.containerView addSubview:model.toViewController.view];
        
        NSTimeInterval duration = model.animationDuration;
        [model.animatedTranstionViewController prepareForTransitionIn:model.fromImageView];
        [model.animatedTranstionViewController performTransitionIn:duration completion:^(BOOL didComplete)
        {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
    else
    {
        model.fromViewController.view.frame = model.toViewController.view.frame;
        
        [transitionContext.containerView addSubview:model.toViewController.view];
        [transitionContext.containerView addSubview:model.fromViewController.view];
        
        NSTimeInterval duration = model.animationDuration;
        [model.animatedTranstionViewController prepareForTransitionOut:model.fromImageView];
        [model.animatedTranstionViewController performTransitionOut:duration completion:^(BOOL didComplete)
         {
             [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
         }];
    }
}

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
