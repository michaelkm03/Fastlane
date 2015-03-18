//
//  VTransitionModel.m
//  victorious
//
//  Created by Patrick Lynch on 12/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTransitionModel.h"
#import "VAnimatedTransition.h"

@implementation VTransitionModel

- (instancetype)initWithTransitionContext:(id <UIViewControllerContextTransitioning>)transitionContext
                               transition:(id<VAnimatedTransition>)transition
{
    self = [super init];
    if (self)
    {
        _fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        _toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        NSParameterAssert( _fromViewController != nil );
        NSParameterAssert( _toViewController != nil );
        
        const BOOL isModalTransition = _toViewController.presentedViewController != nil ||
                                       _fromViewController.presentedViewController != nil;
        if ( isModalTransition )
        {
            _isPresenting = [_toViewController presentedViewController] != _fromViewController;
        }
        else
        {
            UINavigationController *fromNavigationVC = _fromViewController.navigationController;
            _isPresenting = [fromNavigationVC.viewControllers containsObject:_fromViewController]  &&
                            [fromNavigationVC.viewControllers containsObject:_fromViewController];
        }
        _animationDuration = _isPresenting ? transition.transitionInDuration : transition.transitionOutDuration;
        
        if ( [transition respondsToSelector:@selector(requiresImageViewFromOriginViewController)] && [transition requiresImageViewFromOriginViewController] )
        {
            _snapshotOfOriginView = [_fromViewController.view snapshotViewAfterScreenUpdates:NO];
        }
        
        if ( [transition respondsToSelector:@selector(requiresImageViewFromWindow)] && [transition requiresImageViewFromWindow] )
        {
            _snapshotOfOriginView = [[[[UIApplication sharedApplication] windows] firstObject] snapshotViewAfterScreenUpdates:NO];
        }
        
    }
    return self;
}

@end
