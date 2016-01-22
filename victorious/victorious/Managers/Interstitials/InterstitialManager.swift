//
//  InterstitialManager.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

@objc protocol InterstitialListener {
    func newInterstitialHasBeenRegistered()
}

/// A singleton object for managing alerts received from the Victorious API and presenting appripriate
/// intestitial view controllers to the user upon receipt.
class InterstitialManager: NSObject, UIViewControllerTransitioningDelegate, InterstitialViewControllerDelegate, AlertReceiver {
    
    var disabled: Bool = false
    
    /// Returns the interstitial manager singelton
    static let sharedInstance = InterstitialManager()
    
    var dependencyManager: VDependencyManager?
    
    var interstitialListener: InterstitialListener?
    
    private(set) var isShowingInterstital = false
    
    private var registeredAlerts = [Alert]()
    
    private var shownAlerts = [Alert]()
    
    private var presentedInterstitial: InterstitialViewController?
    
    /// Presents modally any available interstitials on the provided presentingg view controller
    func showNextInterstitial( onViewController presentingViewController: UIViewController) -> Bool {
        if !registeredAlerts.isEmpty {
            showInterstitial( alert: registeredAlerts.removeAtIndex(0), presentingViewController: presentingViewController)
            return true
        }
        return false
    }
    
    /// Removes all registered interstitials
    func clearAllRegisteredAlerts() {
        registeredAlerts.removeAll()
    }
    
    private func showInterstitial( alert alert: Alert, presentingViewController: UIViewController) {
        guard !isShowingInterstital,
            let interstitial = dependencyManager?.interstitialViewController(alert: alert) else {
                return
        }
        
        presentedInterstitial = interstitial
        interstitial.interstitialDelegate = self
        
        guard let viewController = interstitial as? UIViewController else {
            return
        }
        
        
        viewController.transitioningDelegate = self
        viewController.modalPresentationStyle = interstitial.preferredModalPresentationStyle()
        presentingViewController.presentViewController(viewController, animated: true, completion: nil)
        
        AcknowledgeAlertOperation(alertID: alert.alertID).queue()
        shownAlerts.append( alert )
        isShowingInterstital = true
    }
    
    // MARK: - AlertReceiver
    
    func onAlertsReceived( alerts: [Alert] ) {
        let newAlerts = alerts.filter { alert in
            !registeredAlerts.contains { $0 == alert } && !shownAlerts.contains { $0 == alert }
        }
        for alert in newAlerts {
            registeredAlerts.append(alert)
            if let interstitialListener = interstitialListener {
                interstitialListener.newInterstitialHasBeenRegistered()
            }
        }
    }
    
    /// MARK: InterstitialViewController
    
    func dismissInterstitial(interstitialViewController: UIViewController) {
        interstitialViewController.dismissViewControllerAnimated(true, completion: nil)
        presentedInterstitial = nil
        self.isShowingInterstital = false
    }
    
    /// MARK: Transition Delegate
        
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentedInterstitial?.presentationAnimator()
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentedInterstitial?.dismissalAnimator()
    }
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return presentedInterstitial?.presentationController(presented, presentingViewController: presenting)
    }
}
