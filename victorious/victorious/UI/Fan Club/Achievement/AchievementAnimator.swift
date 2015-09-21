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
    private let overlay = UIView()
    
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
                
                toViewController.view.frame = containerView.bounds
                fromViewController.view.frame = containerView.bounds
                
                overlay.backgroundColor = UIColor.blackColor()
                
                if isDismissal {
                    
                    containerView.addSubview(fromViewController.view)
                    toViewController.beginAppearanceTransition(true, animated: true)
                    fromViewController.beginAppearanceTransition(false, animated: true)
                    UIView.animateWithDuration(AchievementViewController.AnimationConstants.dismissalDuration, animations: {
                        self.overlay.alpha = 0
                        }, completion: { (completed) in
                            transitionContext.completeTransition(true)
                            toViewController.endAppearanceTransition()
                            fromViewController.endAppearanceTransition()
                    })
                }
                else {
                    
                    overlay.alpha = 0
                    containerView.addSubview(overlay)
                    containerView.v_addFitToParentConstraintsToSubview(overlay)
                    
                    toViewController.beginAppearanceTransition(true, animated: true)
                    fromViewController.beginAppearanceTransition(false, animated: true)
                    UIView.animateWithDuration(AchievementViewController.AnimationConstants.presentationDuration, animations: {
                        self.overlay.alpha = self.overlayOpacity
                        }, completion: { (completed) in
                            containerView.addSubview(toViewController.view)
                            transitionContext.completeTransition(true)
                            toViewController.endAppearanceTransition()
                            fromViewController.endAppearanceTransition()
                    })
                }
        }
        
    }
}