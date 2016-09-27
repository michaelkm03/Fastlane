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
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let destinationVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as? CoachmarkViewController else {
            return
        }

        let containerView = transitionContext.containerView
        containerView.addSubview(destinationVC.view)
        destinationVC.view.alpha = 0.0
        
        // Must set up the blur view here to prevent "flashing"
        // during the transition 
        let blurView = destinationVC.setupBlurView()
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            destinationVC.view.alpha = 1.0
            blurView.effect = UIBlurEffect(style: .Light)
        }, completion: { didFinish in
            transitionContext.completeTransition(didFinish)
        }) 
    }
}
