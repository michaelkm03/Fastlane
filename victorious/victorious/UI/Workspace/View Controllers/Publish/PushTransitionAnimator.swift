//
//  PushTransitionAnimator.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// An animator that imitates the "push" animation
class PushTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    var presenting = true
    var dismissing = false
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return presenting ? 0.325 : 0.35
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toView = transitionContext.view(forKey: UITransitionContextViewKey.to),
            let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)
        else {
            return
        }

        let containerView = transitionContext.containerView
        let backgroundView = presenting ? fromView : toView
        let foregroundView = presenting ? toView : fromView

        containerView.addSubview(backgroundView)
        containerView.addSubview(foregroundView)
        
        if let snapshot = foregroundView.snapshotView(afterScreenUpdates: false), dismissing {
            backgroundView.addSubview(snapshot)
            transitionContext.completeTransition(true)
            return
        }
        
        let width = containerView.bounds.width
        
        let forgroundViewOffscreenTransform = CGAffineTransform(translationX: width, y: 0)
        let forgroundViewStartTransform = presenting ? forgroundViewOffscreenTransform : CGAffineTransform.identity
        let forgroundViewEndTransform = presenting ? CGAffineTransform.identity : forgroundViewOffscreenTransform
        
        let backgroundViewOffscreenTransform = CGAffineTransform(translationX: -width / 3, y: 0)
        let backgroundViewStartTransform = presenting ? CGAffineTransform.identity : backgroundViewOffscreenTransform
        let backgroundViewEndTransform = presenting ? backgroundViewOffscreenTransform : CGAffineTransform.identity
        
        foregroundView.transform = forgroundViewStartTransform
        backgroundView.transform = backgroundViewStartTransform
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: [.curveEaseOut, .allowAnimatedContent],
            animations: {
                foregroundView.transform = forgroundViewEndTransform
                backgroundView.transform = backgroundViewEndTransform
            },
            completion: { complete in
                transitionContext.completeTransition(complete)
                backgroundView.transform = CGAffineTransform.identity
            }
        )
    }
}
