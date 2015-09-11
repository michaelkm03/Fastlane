//
//  ContentViewTransitionDismissAnimator.swift
//  victorious
//
//  Created by Patrick Lynch on 9/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class ContentViewTransitionDismissAnimator : NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()
        
        let animationDuration = self .transitionDuration(transitionContext)
        
        UIView.animateWithDuration(animationDuration,
            animations: {
                fromViewController.view.alpha = 0.0
                fromViewController.view.transform = CGAffineTransformMakeScale(0.1, 0.1)
            },
            completion: { finished in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            }
        )
    }
}
