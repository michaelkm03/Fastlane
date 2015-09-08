//
//  ContentViewPresentationController.swift
//  victorious
//
//  Created by Patrick Lynch on 9/3/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

// WARNING: Delete this?
class ContentViewPresentationController: UIPresentationController {
    
    let dimmingView: UIView
    
    override init(presentedViewController: UIViewController!, presentingViewController: UIViewController!) {
        self.dimmingView = UIView()
        self.dimmingView.backgroundColor = UIColor.redColor()
        
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
    }
    
    override func shouldRemovePresentersView() -> Bool {
        return false
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        self.containerView.addSubview(self.dimmingView)
        self.dimmingView.alpha = 0.0
        
        self.presentedViewController.transitionCoordinator()?.animateAlongsideTransition( { context in
            
            self.dimmingView.alpha = 1.0
            
            }, completion: { context in
                
        })
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        self.presentedViewController.transitionCoordinator()?.animateAlongsideTransition( { context in
            
            self.dimmingView.alpha = 0.0
            
            }, completion: { context in
                
        })
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
    }
}