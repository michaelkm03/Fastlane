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
        _isPresenting = [_toViewController presentedViewController] != _fromViewController;
        _animationDuration = _isPresenting ? transition.transitionInDuration : transition.transitionOutDuration;
        if ( [transition requiresImageViewFromOriginViewController] )
        {
            _snapshotOfOriginView = [_fromViewController.view snapshotViewAfterScreenUpdates:NO];
        }
    }
    return self;
}

@end
