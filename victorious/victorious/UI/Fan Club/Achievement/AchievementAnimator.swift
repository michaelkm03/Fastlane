//
//  AchievementAnimator.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/18/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

class AchievementAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var isDismissal = false
    var overlay = UIView()
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        if isDismissal {
            return LevelUpViewController.AnimationConstants.dismissalDuration
        }
        return LevelUpViewController.AnimationConstants.presentationDuration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        if let containerView = transitionContext.containerView(),
            let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
            let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) {
                
                toViewController.view.frame = containerView.bounds
                fromViewController.view.frame = containerView.bounds
                
                if isDismissal {
                    
                    containerView.addSubview(fromViewController.view)
                    toViewController.beginAppearanceTransition(true, animated: true)
                    fromViewController.beginAppearanceTransition(false, animated: true)
                    UIView.animateWithDuration(LevelUpViewController.AnimationConstants.dismissalDuration, animations: {
                        self.overlay.alpha = 0
                        }, completion: { (completed) in
                            transitionContext.completeTransition(true)
                            toViewController.endAppearanceTransition()
                            fromViewController.endAppearanceTransition()
                    })
                }
                else {
                    
                    overlay.alpha = 0
                    overlay.bounds = containerView.bounds
                    containerView.addSubview(overlay)
                    
                    containerView.addSubview(toViewController.view)
                    toViewController.beginAppearanceTransition(true, animated: true)
                    fromViewController.beginAppearanceTransition(false, animated: true)
                    UIView.animateWithDuration(LevelUpViewController.AnimationConstants.presentationDuration, animations: {
                        self.overlay.alpha = 1
                        }, completion: { (completed) in
                            transitionContext.completeTransition(true)
                            toViewController.endAppearanceTransition()
                            fromViewController.endAppearanceTransition()
                    })
                }
        }
        
    }
}