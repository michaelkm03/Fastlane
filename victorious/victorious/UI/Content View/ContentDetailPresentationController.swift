//
//  ContentDetailPresentationController.swift
//  victorious
//
//  Created by Patrick Lynch on 9/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class ContentDetailPresentationController: UIPresentationController {
    
    override init(presentedViewController: UIViewController!, presentingViewController: UIViewController!) {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
    }
    
    override func presentationTransitionWillBegin() {
        let containerView = self.containerView
        let presentedViewController = self.presentedViewController
        presentedViewController.transitionCoordinator()?.animateAlongsideTransition({ coordinatorContext in
            
        }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator()?.animateAlongsideTransition({ coordinatorContext in
            
        }, completion: nil)
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView().frame = frameOfPresentedViewInContainerView()
    }
    
    override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        let currentDevice = UIDevice.currentDevice().userInterfaceIdiom
        return CGSizeMake(parentSize.width - 40.0, parentSize.height - 80.0)
    }
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        var presentedViewFrame = CGRectZero
        let containerBounds = containerView.bounds
        
        let contentContainer = presentedViewController
        presentedViewFrame.size = sizeForChildContentContainer(contentContainer, withParentContainerSize: containerBounds.size)
        presentedViewFrame.origin.x = 20.0
        presentedViewFrame.origin.y = 40.0
        
        return presentedViewFrame
    }
}