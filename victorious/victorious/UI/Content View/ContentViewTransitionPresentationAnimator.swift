//
//  ContentViewTransitionPresentationAnimator.swift
//  victorious
//
//  Created by Patrick Lynch on 9/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class ContentViewTransitionPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let navController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! VNavigationController
        let toViewController = navController.innerNavigationController?.topViewController as! VNewContentViewController
        
        //let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()
        
        let animationDuration = self.transitionDuration(transitionContext)
        
        toViewController.view.transform = CGAffineTransformMakeScale(0.1, 0.1)
        toViewController.view.layer.shadowColor = UIColor.blackColor().CGColor
        toViewController.view.layer.shadowOffset = CGSizeMake(0.0, 2.0)
        toViewController.view.layer.shadowOpacity = 0.3
        toViewController.view.layer.cornerRadius = 4.0
        toViewController.view.clipsToBounds = true
        
        containerView.addSubview(toViewController.view)
        
        UIView.animateWithDuration(animationDuration,
            animations: { () -> Void in
                toViewController.view.transform = CGAffineTransformIdentity
            },
            completion: { finished in
                transitionContext.completeTransition(finished)
            }
        )
    }
}