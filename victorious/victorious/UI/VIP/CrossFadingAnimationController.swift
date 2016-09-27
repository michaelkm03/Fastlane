//
//  CrossFadingAnimationController.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

struct CrossFadingAnimationControllerOptions {
    let fadeOutDuration: TimeInterval
    let fadeInDuration: TimeInterval
    var transitionDuration: TimeInterval {
        return fadeInDuration + fadeOutDuration
    }
}

class CrossFadingAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    var animationOptions: CrossFadingAnimationControllerOptions
    
    init(animationOptions: CrossFadingAnimationControllerOptions = CrossFadingAnimationControllerOptions(fadeOutDuration: 0.5, fadeInDuration: 0.5)) {
        self.animationOptions = animationOptions
    }
    
    func animateTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toView = transitionContext.viewForKey(UITransitionContextToViewKey),
            let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)
        else {
            return
        }
        
        toView.alpha = 0.0
        let animations = {
            fromView.alpha = 0.0
        }
    
        let animationOptions = self.animationOptions
        UIView.animateWithDuration(animationOptions.fadeOutDuration, animations: animations) { _ in
            fromView.removeFromSuperview()
            transitionContext.containerView().addSubview(toView)
            let animations = {
                toView.alpha = 1.0
                transitionContext.completeTransition(true)
            }
            UIView.animateWithDuration(animationOptions.fadeInDuration, animations: animations)
        }
    }
    
    func transitionDuration(_ transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationOptions.transitionDuration
    }
}
