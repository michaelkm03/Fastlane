//
//  VAlongsidePresentationAnimator.m
//  victorious
//
//  Created by Michael Sena on 7/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAlongsidePresentationAnimator.h"

@implementation VAlongsidePresentationAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    id <VAlongsidePresentation> alongsideVC;
    if ([toViewController conformsToProtocol:@protocol(VAlongsidePresentation)])
    {
        alongsideVC = (id<VAlongsidePresentation>)toViewController;
    }
    if ([fromViewController conformsToProtocol:@protocol(VAlongsidePresentation)])
    {
        alongsideVC = (id<VAlongsidePresentation>)fromViewController;
    }
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0.0f
         usingSpringWithDamping:0.9f
          initialSpringVelocity:0.0f
                        options:kNilOptions
                     animations:^
     {
         if (self.presenting)
         {
             [alongsideVC alongsidePresentation];
             [[transitionContext containerView] addSubview:toView];
             toView.frame = [transitionContext finalFrameForViewController:toViewController];
         }
         else
         {
             [alongsideVC alongsideDismissal];
         }
     }
                     completion:^(BOOL finished)
     {
         [transitionContext completeTransition:YES];
     }];
}

@end
