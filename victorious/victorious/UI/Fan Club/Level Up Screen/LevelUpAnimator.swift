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
        
        if let toView = transitionContext.viewForKey(UITransitionContextToViewKey),
            let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey) {

            let containerView = transitionContext.containerView()
            toView.frame = containerView.bounds
            fromView.frame = containerView.bounds
            
            if isDismissal {
                
                containerView.addSubview(toView)
                containerView.addSubview(fromView)
                
                UIView.animateWithDuration(LevelUpViewController.AnimationConstants.dismissalDuration,
                    animations: {
                        fromView.alpha = 0
                    },
                    completion: { (completed) in
                        fromView.removeFromSuperview()
                        transitionContext.completeTransition(true)
                })
            }
            else {
                
                containerView.addSubview(fromView)
                containerView.addSubview(toView)
                
                UIView.animateWithDuration(LevelUpViewController.AnimationConstants.presentationDuration,
                    animations: {
                        toView.alpha = 1
                    },
                    completion: { (completed) in
                        fromView.removeFromSuperview()
                        transitionContext.completeTransition(true)
                })
            }
        }
        
    }
}
