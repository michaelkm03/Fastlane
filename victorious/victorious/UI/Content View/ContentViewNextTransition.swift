//
//  ContentViewNextTransition.swift
//  victorious
//
//  Created by Patrick Lynch on 9/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

/// A custom transition used to show `VNewContentViewController` with a "split-reveal" style animation.
class ContentViewNextTransition : NSObject, VAnimatedTransition {
    
    func canPerformCustomTransitionFrom(fromViewController: UIViewController?, to toViewController: UIViewController) -> Bool {
        return toViewController is VNewContentViewController && (fromViewController == nil || fromViewController is VNewContentViewController)
    }
    
    func prepareForTransitionIn(model: VTransitionModel) {
        model.toViewController.view.alpha = 0.0
    }
    
    func prepareForTransitionOut(model: VTransitionModel) {
        model.fromViewController.view.alpha = 1.0
    }
    
    func performTransitionIn(model: VTransitionModel, completion: ((Bool) -> Void)?) {
        UIView.animateWithDuration( model.animationDuration,
            delay: 0.0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.0,
            options: [],
            animations: {
                model.toViewController.view.alpha = 1.0
            },
            completion: { finished in
                completion?(finished)
            }
        )
    }
    
    func performTransitionOut(model: VTransitionModel, completion: ((Bool) -> Void)?) {
        UIView.animateWithDuration( model.animationDuration,
            delay: 0.0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.2,
            options: [],
            animations: {
                model.fromViewController.view.alpha = 0.0
            },
            completion: { finished in
                completion?(finished)
            }
        )
    }
    
    var requiresImageViewFromOriginViewController: Bool {
        return true
    }
    
    var requiresImageViewFromWindow: Bool {
        return false
    }
    
    var transitionInDuration: NSTimeInterval {
        return 0.3
    }
    
    var transitionOutDuration: NSTimeInterval {
        return 0.2
    }
}
