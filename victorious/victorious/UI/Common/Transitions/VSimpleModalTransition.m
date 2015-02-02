//
//  VSimpleModalTransition.m
//  victorious
//
//  Created by Patrick Lynch on 12/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSimpleModalTransition.h"
#import "VTransitionModel.h"

@implementation VSimpleModalTransition

#pragma mark - VAnimatedTransitionViewController

- (id<VSimpleModalTransitionPresentedViewController>)viewControllerFromModel:(VTransitionModel *)model
{
    if ( model.isPresenting )
    {
        NSParameterAssert( [model.toViewController conformsToProtocol:@protocol( VSimpleModalTransitionPresentedViewController )] );
        return (id<VSimpleModalTransitionPresentedViewController>) model.toViewController;
    }
    else
    {
        NSParameterAssert( [model.fromViewController conformsToProtocol:@protocol( VSimpleModalTransitionPresentedViewController )] );
        return (id<VSimpleModalTransitionPresentedViewController>) model.fromViewController;
    }
}

- (void)prepareForTransitionIn:(VTransitionModel *)model
{
    id<VSimpleModalTransitionPresentedViewController> vc = [self viewControllerFromModel:model];
    
    if ( model != nil )
    {
        [vc.view addSubview:model.snapshotOfOriginView];
        [vc.view sendSubviewToBack:model.snapshotOfOriginView];
    }
    
    vc.backgroundScreen.alpha = 0.0f;
    vc.modalContainer.alpha = 0.0f;
    
    vc.modalContainer.transform = [self scaledDownTransform];
    
    [vc.view setNeedsDisplay];
}

- (void)performTransitionIn:(VTransitionModel *)model completion:(void (^)(BOOL))completion
{
    id<VSimpleModalTransitionPresentedViewController> vc = [self viewControllerFromModel:model];
    
    NSTimeInterval screenDuration = model.animationDuration * 0.3f;
    NSTimeInterval modalDuration = model.animationDuration * 0.7f;
    
    [UIView animateWithDuration:screenDuration animations:^void
     {
         vc.backgroundScreen.alpha = 0.5f;
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:modalDuration delay:0.0f
              usingSpringWithDamping:0.7f
               initialSpringVelocity:0.1f
                             options:kNilOptions animations:^void
          {
              vc.modalContainer.alpha = 1.0f;
              vc.modalContainer.transform = CGAffineTransformIdentity;
          }
                          completion:completion];
     }];
}

- (void)prepareForTransitionOut:(VTransitionModel *)model
{
}

- (void)performTransitionOut:(VTransitionModel *)model completion:(void (^)(BOOL))completion
{
    id<VSimpleModalTransitionPresentedViewController> vc = [self viewControllerFromModel:model];
    
    NSTimeInterval screenDuration = model.animationDuration * 0.3f;
    NSTimeInterval modalDuration = model.animationDuration * 0.6f;
    
    [UIView animateWithDuration:modalDuration delay:0.0f
         usingSpringWithDamping:0.9f
          initialSpringVelocity:0.5f
                        options:kNilOptions animations:^void
     {
         vc.modalContainer.alpha = 0.0f;
         vc.modalContainer.transform = [self scaledDownTransform];
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:screenDuration animations:^void
          {
              vc.backgroundScreen.alpha = 0.0f;
          }
                          completion:completion];
     }];
}

- (BOOL)requiresImageViewFromOriginViewController
{
    return YES;
}

- (NSTimeInterval)transitionInDuration
{
    return 0.7f;
}

- (NSTimeInterval)transitionOutDuration
{
    return 0.5f;
}

#pragma mark - Helpers

- (CGAffineTransform)scaledDownTransform
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformMakeScale( 0.4f, 0.4f );
    return transform;
}

@end
