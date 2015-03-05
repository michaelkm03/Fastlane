//
//  VPresentWithBlurTransition.m
//  victorious
//
//  Created by Patrick Lynch on 3/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPresentWithBlurTransition.h"
#import "VTransitionModel.h"

@implementation VPresentWithBlurTransition

- (UIViewController<VPresentWithBlurViewController> *)toViewControllerFromModel:(VTransitionModel *)model
{
    UIViewController<VPresentWithBlurViewController> *toViewController;
    
    UIViewController *targetViewController = model.isPresenting ? model.toViewController : model.fromViewController;
    
    if ( [targetViewController isKindOfClass:[UINavigationController class]] )
    {
        UINavigationController *navController = (UINavigationController *)targetViewController;
        toViewController = ((UIViewController<VPresentWithBlurViewController> *)navController.viewControllers.firstObject);
    }
    else
    {
        toViewController = (UIViewController<VPresentWithBlurViewController> *)model.fromViewController;
    }
    
    NSAssert( toViewController != nil && [toViewController conformsToProtocol:@protocol(VPresentWithBlurViewController)],
             @"Presented view controller must conform to `VPresentationWithBlurViewController` protocol." );
    
    return toViewController;
}

- (void)prepareForTransitionIn:(VTransitionModel *)model
{
    UIViewController<VPresentWithBlurViewController> *toViewController = [self toViewControllerFromModel:model];
    toViewController.blurredBackgroundView.alpha = 0.0f;
    
    [toViewController.view addSubview:model.snapshotOfOriginView];
    [toViewController.view sendSubviewToBack:model.snapshotOfOriginView];
    [toViewController.stackedElements enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop)
     {
         view.transform = CGAffineTransformMakeTranslation( 0.0f, 100.0f );
         view.alpha = 0.0f;
     }];

}

- (void)performTransitionIn:(VTransitionModel *)model completion:(void (^)(BOOL))completion
{
    UIViewController<VPresentWithBlurViewController> *toViewController = [self toViewControllerFromModel:model];
    
    [UIView animateWithDuration:model.animationDuration * 0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^
     {
         toViewController.blurredBackgroundView.alpha = 1.0f;
     }
                     completion:^(BOOL finished)
     {
         [toViewController.stackedElements enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop)
          {
              CGFloat delay = (CGFloat)idx * 0.05f;
              [UIView animateWithDuration:model.animationDuration * 0.75f delay:delay
                   usingSpringWithDamping:0.7
                    initialSpringVelocity:1.0f
                                  options:kNilOptions animations:^
               {
                   view.transform = CGAffineTransformMakeTranslation( 0.0f, 0.0f );
                   view.alpha = 1.0f;
               }
                               completion:^(BOOL finished)
               {
                   if ( idx == toViewController.stackedElements.count-1 )
                   {
                       completion( finished );
                   }
               }];
          }];
     }];
}

- (void)prepareForTransitionOut:(VTransitionModel *)model
{
    UIViewController<VPresentWithBlurViewController> *toViewController = [self toViewControllerFromModel:model];
    toViewController.blurredBackgroundView.alpha = 1.0f;
}

- (void)performTransitionOut:(VTransitionModel *)model completion:(void (^)(BOOL))completion
{
    UIViewController<VPresentWithBlurViewController> *toViewController = [self toViewControllerFromModel:model];
    [toViewController.stackedElements.reversedOrderedSet enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop)
     {
         CGFloat delay = (CGFloat)idx * 0.05f;
         [UIView animateWithDuration:model.animationDuration delay:delay
              usingSpringWithDamping:1.0f
               initialSpringVelocity:0.5f
                             options:UIViewAnimationOptionCurveEaseOut
                          animations:^
          {
              view.transform = CGAffineTransformMakeTranslation( 0.0f, 100.0f );
              view.alpha = 0.0f;
          }
                          completion:^(BOOL finished)
          {
              if ( idx == toViewController.stackedElements.count-1 )
              {
                  completion( finished );
              }
          }];
     }];
    
    [UIView animateWithDuration:model.animationDuration
                          delay:model.animationDuration * 0.5f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         model.snapshotOfOriginView.alpha = 0.0f;
         toViewController.blurredBackgroundView.alpha = 0.0f;
     } completion:nil];
}

- (BOOL)requiresImageViewFromOriginViewController
{
    return YES;
}

- (NSTimeInterval)transitionInDuration
{
    return 0.75f;
}

- (NSTimeInterval)transitionOutDuration
{
    return 0.5f;
}

@end
