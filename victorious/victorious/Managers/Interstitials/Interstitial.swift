//
//  Interstitial.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// View controllers that wish to be presented as interstitials should conform to this protocol.
///
/// To create an alert locally and schedule it with `InterstitialManager`
///
/// - Construct an alert locally
/// - Call `onAlertsReceived` on the singleton object `InterstitialManager`
///
/// Then the alert will be presented with the UI defined in `InterstitialAlertViewController`.
protocol Interstitial: class {
    
    /// The `Alert` property being presented by this `Interstitial`
    var alert: Alert? { get set }
    
    /// A delegate to be informed of interstitial events
    weak var interstitialDelegate: InterstitialDelegate? { get set }
    
    /// Returns an animator object for animating the presentation of the interstitial view controller
    func presentationAnimator() -> UIViewControllerAnimatedTransitioning?
    
    /// Returns an animator object for animating the dismissal of the interstitial view controller
    func dismissalAnimator() -> UIViewControllerAnimatedTransitioning?
    
    /// Returns a presentation controller for animating the presentation and dismissal of the view controller
    func presentationController(_ presentedViewController: UIViewController, presentingViewController: UIViewController?) -> UIPresentationController
    
    /// Returns the modal presentation style preferred by this view controller
    func preferredModalPresentationStyle() -> UIModalPresentationStyle
}

protocol InterstitialDelegate: class {
    
    /// Informs the delegate that the user wants to dismiss the interstitial
    func dismissInterstitial(_ interstitialViewController: UIViewController)

    /// Dismisses the current interstitial on screen with the specified alert type.
    func dismissCurrentInterstitial(of alertType: AlertType)
}
