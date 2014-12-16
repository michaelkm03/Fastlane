//
//  VPurchaseViewController_Transitions.m
//  victorious
//
//  Created by Patrick Lynch on 12/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPurchaseViewController+Transitions.h"

@implementation VPurchaseViewController (Transitions)

#pragma mark - VAnimatedTransitionViewController

- (void)prepareForTransitionIn:(UIView *)snapshotOfOriginView
{
    if ( snapshotOfOriginView != nil )
    {
        [self.view addSubview:snapshotOfOriginView];
        [self.view sendSubviewToBack:snapshotOfOriginView];
    }
    
    self.backgroundScreen.alpha = 0.0f;
    self.modalContainer.alpha = 0.0f;
    
    self.modalContainer.transform = [self scaledDownTransform];
    
    [self.view setNeedsDisplay];
}

- (void)performTransitionIn:(NSTimeInterval)duration completion:(void (^)(BOOL))completion
{
    NSTimeInterval screenDuration = self.transitionInDuration * 0.3f;
    NSTimeInterval modalDuration = self.transitionInDuration * 0.7f;
    
    [UIView animateWithDuration:screenDuration animations:^void
     {
         self.backgroundScreen.alpha = 0.5f;
     }
                              completion:^(BOOL finished)
     {
         [UIView animateWithDuration:modalDuration delay:0.0f
              usingSpringWithDamping:0.7f
               initialSpringVelocity:0.1f
                             options:kNilOptions animations:^void
          {
              self.modalContainer.alpha = 1.0f;
              self.modalContainer.transform = CGAffineTransformIdentity;
          }
                                   completion:completion];
     }];
}

- (void)prepareForTransitionOut:(UIView *)snapshotOfOriginView
{
}

- (void)performTransitionOut:(NSTimeInterval)duration completion:(void (^)(BOOL))completion
{
    NSTimeInterval screenDuration = self.transitionOutDuration * 0.3f;
    NSTimeInterval modalDuration = self.transitionOutDuration * 0.6f;
    
    [UIView animateWithDuration:modalDuration delay:0.0f
         usingSpringWithDamping:0.9f
          initialSpringVelocity:0.5f
                        options:kNilOptions animations:^void
     {
         self.modalContainer.alpha = 0.0f;
         self.modalContainer.transform = [self scaledDownTransform];
     }
                              completion:^(BOOL finished)
     {
         [UIView animateWithDuration:screenDuration animations:^void
          {
              self.backgroundScreen.alpha = 0.0f;
          }
                                   completion:completion];
     }];
}

- (NSTimeInterval)transitionInDuration
{
    return 0.7f;
}

- (NSTimeInterval)transitionOutDuration
{
    return 0.5f;
}

- (BOOL)requiresImageViewFromOriginViewController
{
    return YES;
}

#pragma mark - Helpers

- (CGAffineTransform)scaledDownTransform
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformMakeScale( 0.4f, 0.4f );
    return transform;
}

@end
