//
//  CoachmarkDismissAnimationController.swift
//  victorious
//
//  Created by Darvish Kamalia on 8/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import UIKit

class CoachmarkDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard
            let originVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? CoachmarkViewController,
            let containerView = transitionContext.containerView()
        else {
            return
        }
        
        UIView.animateWithDuration(transitionDuration(transitionContext), animations: {
            originVC.view.alpha = 0.0
        }) { didFinish in
            transitionContext.completeTransition(didFinish)
        }
    }
}