//
//  CrossFadingAnimationController.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

struct CrossFadingAnimationControllerOptions {
    let fadeOutDuration: NSTimeInterval
    let fadeInDuration: NSTimeInterval
    var transitionDuration: NSTimeInterval {
        return fadeInDuration + fadeOutDuration
    }
}

class CrossFadingAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    var animationOptions = CrossFadingAnimationControllerOptions(fadeOutDuration: 0.5, fadeInDuration: 0.5)
    
    init(animationOptions: CrossFadingAnimationControllerOptions? = nil) {
        if let animationOptions = animationOptions {
            self.animationOptions = animationOptions
        }
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toView = transitionContext.viewForKey(UITransitionContextToViewKey),
            let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey),
            let containerView = transitionContext.containerView()
        else {
            return
        }
        toView.alpha = 0.0
    
        let animationOptions = self.animationOptions
        UIView.animateWithDuration(animationOptions.fadeOutDuration, animations: { 
            fromView.alpha = 0.0
        }) { _ in
            fromView.removeFromSuperview()
            containerView.addSubview(toView)
            UIView.animateWithDuration(animationOptions.fadeInDuration, animations: { 
                toView.alpha = 1.0
                transitionContext.completeTransition(true)
            })
        }
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return animationOptions.transitionDuration
    }
}
