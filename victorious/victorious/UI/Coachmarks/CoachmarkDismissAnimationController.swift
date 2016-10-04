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
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let originVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? CoachmarkViewController
        else {
            return
        }
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            originVC.view.alpha = 0.0
        }) { didFinish in
            transitionContext.completeTransition(didFinish)
        }
    }
}
