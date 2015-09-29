//
//  AchievementAnimator.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/18/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

class AchievementAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let overlayOpacity: CGFloat = 0.75
    
    var isDismissal = false
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        if isDismissal {
            return AchievementViewController.AnimationConstants.dismissalDuration
        }
        return AchievementViewController.AnimationConstants.presentationDuration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        if let containerView = transitionContext.containerView(),
            let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
            let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) {
                
                let toView = toViewController.view
                let fromView = fromViewController.view
                toView.frame = containerView.bounds
                fromView.frame = containerView.bounds
                
                if isDismissal {
                    
                    toViewController.beginAppearanceTransition(true, animated: true)
                    UIView.animateWithDuration(transitionDuration(transitionContext),
                        animations: { () in
                            fromView.center.y += containerView.bounds.size.height
                        },
                        completion: { (completed) in
                            transitionContext.completeTransition(completed)
                            toViewController.endAppearanceTransition()
                    })
                }
                else {
                    
                    containerView.addSubview(toView)
                    containerView.v_addFitToParentConstraintsToSubview(toView)
                    
                    // Position the presented view off the top of the container view
                    toView.frame = transitionContext.finalFrameForViewController(toViewController)
                    toView.center.y += containerView.bounds.size.height
                    
                    fromViewController.beginAppearanceTransition(false, animated: true)
                    // Animate the presented view to it's final position
                    UIView.animateWithDuration(transitionDuration(transitionContext) + 0.3,
                        delay: 0.3,
                        usingSpringWithDamping: 0.7,
                        initialSpringVelocity: 0.2,
                        options: .CurveEaseIn,
                        animations: {
                            toView.center.y -= containerView.bounds.size.height
                        },
                        completion: { (completed) in
                            transitionContext.completeTransition(completed)
                            fromViewController.endAppearanceTransition()
                    })
                }
        }
        
    }
}