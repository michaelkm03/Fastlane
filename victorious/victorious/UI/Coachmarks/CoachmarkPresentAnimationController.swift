//
//  CoachmarkPresentAnimationController.swift
//  victorious
//
//  Created by Darvish Kamalia on 8/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import UIKit

class CoachmarkPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard
            let destinationVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as? CoachmarkViewController,
            let containerView = transitionContext.containerView()
        else {
            return
        }
        
        containerView.addSubview(destinationVC.view)
        destinationVC.view.alpha = 0.0
        
        // Must set up the blur view here to prevent "flashing"
        // during the transition 
        let blurView = destinationVC.setupBlurView()
        
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
            destinationVC.view.alpha = 1.0
            blurView.effect = UIBlurEffect(style: .Light)
        }) { didFinish in
            transitionContext.completeTransition(didFinish)
        }
    }
}