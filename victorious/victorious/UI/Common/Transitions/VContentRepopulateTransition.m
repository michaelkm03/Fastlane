//
//  VContentRepopulateTransition.m
//  victorious
//
//  Created by Patrick Lynch on 2/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VContentRepopulateTransition.h"
#import "VTransitionModel.h"

@implementation VContentRepopulateTransition

- (void)prepareForTransitionIn:(VTransitionModel *)model
{
    model.toViewController.view.alpha = 0.0f;
}

- (void)performTransitionIn:(VTransitionModel *)model completion:(void (^)(BOOL))completion
{
    [UIView animateWithDuration:model.animationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^
     {
         model.toViewController.view.alpha = 1.0f;
     }
                     completion:completion];
}

- (void)prepareForTransitionOut:(VTransitionModel *)model
{
    model.fromViewController.view.alpha = 1.0f;
}

- (void)performTransitionOut:(VTransitionModel *)model completion:(void (^)(BOOL))completion
{
    [UIView animateWithDuration:model.animationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^
     {
         model.fromViewController.view.alpha = 0.0f;
     }
                     completion:completion];
}

- (BOOL)requiresImageViewFromOriginViewController
{
    return YES;
}

- (NSTimeInterval)transitionInDuration
{
    return 0.3f;
}

- (NSTimeInterval)transitionOutDuration
{
    return 0.2f;
}

@end
