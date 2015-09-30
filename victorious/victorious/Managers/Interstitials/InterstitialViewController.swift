//
//  InterstitialViewController.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// View controllers that wish to be presented as interstitials should conform to this protocol
protocol InterstitialViewController: class {
    
    /// A delegate to be informed of interstitial events
    weak var interstitialDelegate: InterstitialViewControllerDelegate? { get set }
    
    /// Returns an animator object for animating the presentation of the interstitial view controller
    func presentationAnimator() -> UIViewControllerAnimatedTransitioning
    
    /// Returns an animator object for animating the dismissal of the interstitial view controller
    func dismissalAnimator() -> UIViewControllerAnimatedTransitioning
    
    /// Returns a presentation controller for animating the presentation and dismissal of the view controller
    func presentationController(presentedViewController: UIViewController, presentingViewController: UIViewController) -> UIPresentationController
    
    /// Returns the modal presentation style preferred by this view controller
    func preferredModalPresentationStyle() -> UIModalPresentationStyle
}

protocol InterstitialViewControllerDelegate: class {
    
    /// Informs the delegate that the user wants to dismiss the interstitial
    func dismissInterstitial(interstitialViewController: UIViewController)
}
