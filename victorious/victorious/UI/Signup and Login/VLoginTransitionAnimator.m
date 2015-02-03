////
////  VLoginTransitionAnimator.m
////  victorious
////
////  Created by Gary Philipp on 5/19/14.
////  Copyright (c) 2014 Victorious. All rights reserved.
////
//
//#import "VLoginTransitionAnimator.h"
//#import "VLoginViewController.h"
//#import "VLoginWithEmailViewController.h"
//
//@implementation VLoginTransitionAnimator
//
//- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
//{
//    return 0.6f;
//}
//
//- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
//{
//    UIView                         *containerView = [transitionContext containerView];
//    NSTimeInterval                  duration = [self transitionDuration:transitionContext];
//    
//    if (self.presenting)
//    {
//        VLoginViewController           *fromViewController = (VLoginViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//        VLoginWithEmailViewController  *toViewController = (VLoginWithEmailViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//
//        //  Get a snapshot of the thing we are transitioning from
//        UIView *snapshot = [fromViewController.transitionPlaceholder snapshotViewAfterScreenUpdates:NO];
//        snapshot.frame = [containerView convertRect:fromViewController.transitionPlaceholder.frame fromView:fromViewController.transitionPlaceholder.superview];
//        fromViewController.transitionPlaceholder.hidden = YES;
//        
//        //  Set up the initial view states
//        toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
//        toViewController.view.alpha = 0.0;
//        toViewController.transitionPlaceholder.hidden = YES;
//        
//        [containerView addSubview:toViewController.view];
//        [containerView addSubview:snapshot];
//        
//        [UIView animateWithDuration:duration animations:^{
//            // Fade in the second view controller's view
//            toViewController.view.alpha = 1.0;
//                
//            // Move the cell snapshot so it's over the second view controller's image view
//            CGRect frame = [containerView convertRect:toViewController.transitionPlaceholder.frame fromView:toViewController.view];
//            snapshot.frame = frame;
//        } completion:^(BOOL finished)
//         {
//             // Clean up
//             toViewController.transitionPlaceholder.hidden = NO;
//             fromViewController.transitionPlaceholder.hidden = NO;
//             [snapshot removeFromSuperview];
//             
//             // Declare that we've finished
//             [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
//        }];
//    }
//    else
//    {
//        VLoginWithEmailViewController  *fromViewController = (VLoginWithEmailViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//        VLoginViewController           *toViewController = (VLoginViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//
//        // Get a snapshot of the image view
//        UIView *snapshot = [fromViewController.transitionPlaceholder snapshotViewAfterScreenUpdates:NO];
//        snapshot.frame = [containerView convertRect:fromViewController.transitionPlaceholder.frame fromView:fromViewController.transitionPlaceholder.superview];
//        fromViewController.transitionPlaceholder.hidden = YES;
//        
//        // Get the view we'll animate to
//        toViewController.transitionPlaceholder.hidden = YES;
//        
//        // Setup the initial view states
//        toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
//        [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
//        [containerView addSubview:snapshot];
//        
//        [UIView animateWithDuration:duration animations:^{
//            // Fade out the source view controller
//            fromViewController.view.alpha = 0.0;
//            
//            // Move the image view
//            snapshot.frame = [containerView convertRect:toViewController.transitionPlaceholder.frame fromView:toViewController.transitionPlaceholder.superview];
//        } completion:^(BOOL finished) {
//            // Clean up
//            [snapshot removeFromSuperview];
//            fromViewController.transitionPlaceholder.hidden = NO;
//            toViewController.transitionPlaceholder.hidden = NO;
//            
//            // Declare that we've finished
//            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
//        }];
//    }
//}
//
//@end
