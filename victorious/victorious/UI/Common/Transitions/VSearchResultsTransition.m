//
//  VSearchResultsTransition.m
//  victorious
//
//  Created by Lawrence Leach on 2/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSearchResultsTransition.h"
#import "VDiscoverContainerViewController.h"

@implementation VSearchResultsTransition

- (void)prepareForTransitionIn:(VTransitionModel *)model
{
    model.toViewController.view.hidden = YES;
    model.toViewController.view.alpha = 0.0f;
}

- (void)performTransitionIn:(VTransitionModel *)model completion:(void (^)(BOOL))completion
{
    [UIView animateWithDuration:model.animationDuration animations:^
    {
        __block VDiscoverContainerViewController *discoverVC = (VDiscoverContainerViewController *)model.fromViewController.childViewControllers.firstObject;
        
        [model.fromViewController.childViewControllers enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL *stop)
        {
            [vc.childViewControllers enumerateObjectsUsingBlock:^(UIViewController *vc2, NSUInteger idx, BOOL *stop)
             {
                 discoverVC = (VDiscoverContainerViewController *)vc2.childViewControllers.firstObject;
             }];

        }];
        
//        discoverVC.searchBarPositionContraint.constant -= 56.0f;
        [discoverVC.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        model.toViewController.view.hidden = NO;
        model.toViewController.view.alpha = 1.0f;
    }];
}

- (void)prepareForTransitionOut:(VTransitionModel *)model
{
    
}

- (void)performTransitionOut:(VTransitionModel *)model completion:(void (^)(BOOL))completion
{
    
}

- (BOOL)requiresImageViewFromOriginViewController
{
    return NO;
}

- (NSTimeInterval)transitionInDuration
{
    return 0.3f;
}

- (NSTimeInterval)transitionOutDuration
{
    return 0.3;
}

@end
