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
    
    var presenting: Bool = true
    var dismissing: Bool = false
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return presenting ? 0.325 : 0.35
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toView = transitionContext.viewForKey(UITransitionContextToViewKey),
            let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey) else {
                return
        }

        let containerView = transitionContext.containerView()
        let backgroundView = presenting ? fromView : toView
        let foregroundView = presenting ? toView : fromView

        containerView.addSubview(backgroundView)
        containerView.addSubview(foregroundView)
        
        if let snapshot = foregroundView.snapshotViewAfterScreenUpdates(false) where dismissing {
            backgroundView.addSubview(snapshot)
            transitionContext.completeTransition(true)
            return
        }
        
        let width = containerView.bounds.width
        
        let forgroundViewOffscreenTransform = CGAffineTransformMakeTranslation(width, 0)
        let forgroundViewStartTransform = presenting ? forgroundViewOffscreenTransform : CGAffineTransformIdentity
        let forgroundViewEndTransform = presenting ? CGAffineTransformIdentity : forgroundViewOffscreenTransform
        
        let backgroundViewOffscreenTransform = CGAffineTransformMakeTranslation(-width / 3, 0)
        let backgroundViewStartTransform = presenting ? CGAffineTransformIdentity : backgroundViewOffscreenTransform
        let backgroundViewEndTransform = presenting ? backgroundViewOffscreenTransform : CGAffineTransformIdentity
        
        foregroundView.transform = forgroundViewStartTransform
        backgroundView.transform = backgroundViewStartTransform
        
        UIView.animateWithDuration(transitionDuration(transitionContext),
                                   delay: 0,
                                   options: [.CurveEaseOut, .AllowAnimatedContent],
                                   animations: {
                                    foregroundView.transform = forgroundViewEndTransform
                                    backgroundView.transform = backgroundViewEndTransform
            },
                                   completion: { complete in
                                    transitionContext.completeTransition(complete)
                                    backgroundView.transform = CGAffineTransformIdentity
        })
    }
    
}
