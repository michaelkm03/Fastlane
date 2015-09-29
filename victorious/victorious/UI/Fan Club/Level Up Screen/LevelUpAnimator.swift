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
                
                fromViewController.beginAppearanceTransition(false, animated: true)
                toViewController.beginAppearanceTransition(true, animated: true)
                
                UIView.animateWithDuration(LevelUpViewController.AnimationConstants.dismissalDuration, animations: {
                    fromViewController.view.alpha = 0
                    }, completion: { (completed) in
                        transitionContext.completeTransition(true)
                        toViewController.endAppearanceTransition()
                        fromViewController.endAppearanceTransition()
                })
            }
            else {
                
                toViewController.view.alpha = 0
                containerView.addSubview(toViewController.view)
                
                fromViewController.beginAppearanceTransition(false, animated: true)
                toViewController.beginAppearanceTransition(true, animated: true)
                
                UIView.animateWithDuration(LevelUpViewController.AnimationConstants.presentationDuration, animations: {
                    toViewController.view.alpha = 1
                    }, completion: { (completed) in
                        transitionContext.completeTransition(true)
                        fromViewController.endAppearanceTransition()
                        toViewController.endAppearanceTransition()
                })
            }
        }
        
    }
}
