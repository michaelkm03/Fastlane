//
//  InterstitialAlertAnimator.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/18/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

class InterstitialAlertAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let isDismissing: Bool
    init(isDismissing: Bool) {
        self.isDismissing = isDismissing
    }
    
    fileprivate struct Constants {
        static let dismissalDuration = 0.3
        static let presentationDuration = 0.5
    }
    
    func transitionDuration(_ transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if isDismissing {
            return Constants.dismissalDuration
        }
        return Constants.presentationDuration
    }
    
    func animateTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        
        if let toViewController = transitionContext.viewController(forKey: UITransitionContextToViewControllerKey),
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextFromViewControllerKey) {

                let containerView = transitionContext.containerView()
                let toView = toViewController.view
                let fromView = fromViewController.view
                toView.frame = containerView.bounds
                fromView.frame = containerView.bounds
                
                if isDismissing {
                    
                    // Because this is a custom modal transition, this needs to be called so that 
                    // viewWillDisappear gets called on the presenting view controller
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
