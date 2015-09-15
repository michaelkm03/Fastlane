//
//  LevelUpAnimator.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit
import Foundation

class LevelUpAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var isDismissal = false
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        if isDismissal {
            return LevelUpViewController.AnimationConstants.dismissalDuration
        }
        return LevelUpViewController.AnimationConstants.presentationDuration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let containerView = transitionContext.containerView()
        
        if let toViewController = toViewController, fromViewController = fromViewController {
            
            toViewController.view.frame = containerView.bounds
            fromViewController.view.frame = containerView.bounds
            
            if isDismissal {
                
                containerView.addSubview(fromViewController.view)
                
                UIView.animateWithDuration(LevelUpViewController.AnimationConstants.dismissalDuration, animations: { () -> Void in
                    fromViewController.view.alpha = 0
                    }, completion: { (completed) -> Void in
                        transitionContext.completeTransition(true)
                })
            }
            else {
                toViewController.view.alpha = 0
                containerView.addSubview(toViewController.view)
                
                UIView.animateWithDuration(LevelUpViewController.AnimationConstants.presentationDuration, animations: { () -> Void in
                    toViewController.view.alpha = 1
                    }, completion: { (completed) -> Void in
                        transitionContext.completeTransition(true)
                })
            }
        }
        
    }
}
