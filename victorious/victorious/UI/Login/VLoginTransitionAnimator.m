//
//  VLoginTransitionAnimator.m
//  victorious
//
//  Created by Gary Philipp on 5/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VLoginTransitionAnimator.h"
#import "VLoginViewController.h"
#import "VLoginWithEmailViewController.h"

@implementation VLoginTransitionAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    VLoginViewController*           fromViewController = (VLoginViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    VLoginWithEmailViewController*  toViewController = (VLoginWithEmailViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView*                         containerView = [transitionContext containerView];
    NSTimeInterval                  duration = [self transitionDuration:transitionContext];
    
    if (self.presenting)
    {
        //  Get a snapshot of the thing we are transitioning from
    //    UIView *cellSnapshot = [transitioningView snapshotViewAfterScreenUpdates];
    //    cellSnapshot = [containerView convertRect:cell.imageView.frame fromView:cell.imageView.superview];
    //    transitioningView.hidden = YES;
        
        //  Set up the initial view states
        toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
        toViewController.view.alpha = 0.0;
    //    toViewController.transitioningView.hidden = YES;
        
        [containerView addSubview:toViewController.view];
    //    [containerView addSubview:cellSnapshot];
        
        [UIView animateWithDuration:duration animations:^{
            // Fade in the second view controller's view
            toViewController.view.alpha = 1.0;
                
            // Move the cell snapshot so it's over the second view controller's image view
//            CGRect frame = [containerView convertRect:toViewController.transitioningView.frame fromView:toViewController.view];
//            cellSnapshot.frame = frame;
        } completion:^(BOOL finished)
         {
             // Clean up
//             toViewController.transitioningView.hidden = NO;
//             cell.hidden = NO;
//             [cellImageSnapshot removeFromSuperview];
             
             // Declare that we've finished
             [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }
    else
    {
        // Get a snapshot of the image view
//        UIView *imageSnapshot = [fromViewController.imageView snapshotViewAfterScreenUpdates:NO];
//        imageSnapshot.frame = [containerView convertRect:fromViewController.imageView.frame fromView:fromViewController.imageView.superview];
//        fromViewController.imageView.hidden = YES;
        
        // Get the cell we'll animate to
//        DSLThingCell *cell = [toViewController collectionViewCellForThing:fromViewController.thing];
//        cell.imageView.hidden = YES;
        
        // Setup the initial view states
        toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
        [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
//        [containerView addSubview:imageSnapshot];
        
        [UIView animateWithDuration:duration animations:^{
            // Fade out the source view controller
            fromViewController.view.alpha = 0.0;
            
            // Move the image view
//            imageSnapshot.frame = [containerView convertRect:cell.imageView.frame fromView:cell.imageView.superview];
        } completion:^(BOOL finished) {
            // Clean up
//            [imageSnapshot removeFromSuperview];
//            fromViewController.imageView.hidden = NO;
//            cell.imageView.hidden = NO;
            
            // Declare that we've finished
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }
}

@end
