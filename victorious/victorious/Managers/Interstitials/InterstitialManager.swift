//
//  InterstitialManager.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

protocol InterstitialListener {
    func newInterstitialHasBeenRegistered()
}

/// A singleton object for managing alerts received from the Victorious API and presenting appropriate
/// intestitial view controllers to the user upon receipt.
class InterstitialManager: NSObject, UIViewControllerTransitioningDelegate, InterstitialDelegate, AlertReceiver {
    
    var disabled: Bool = false
    
    /// Returns the interstitial manager singelton
    static let sharedInstance = InterstitialManager()
    
    var dependencyManager: VDependencyManager?
    
    var interstitialListener: InterstitialListener?
    
    private(set) var isShowingInterstital = false
    
    private var registeredAlerts = [Alert]()
    
    private var shownAlerts = [Alert]()
    
    private var presentedInterstitial: Interstitial?
    
    /// Presents modally any available interstitials on the provided presenting view controller
    func showNextInterstitial(onViewController presentingViewController: UIViewController) -> Bool {
        if !registeredAlerts.isEmpty {
            let alertToShow = registeredAlerts.removeFirst()
            
            showInterstitial(with: alertToShow, onto: presentingViewController)
            
            return true
        }
        return false
    }
    
    /// Removes all registered interstitials
    func clearAllRegisteredAlerts() {
        registeredAlerts.removeAll()
    }
    
    private func showInterstitial(with alert: Alert, onto presentingViewController: UIViewController) {
        guard
            !isShowingInterstital,
            let interstitial = dependencyManager?.interstitialViewController(alert: alert)
        else {
            return
        }
        
        presentedInterstitial = interstitial
        interstitial.interstitialDelegate = self
        
        guard let interstitialViewController = interstitial as? UIViewController else {
            return
        }
        
        switch alert.alertType {
            case .Toast, .WebSocketError:
            addInterstitial(interstitialViewController, toParent: presentingViewController)
            case .Achievement, .LevelUp, .StatusUpdate, .ClientSideCreated:
                interstitialViewController.transitioningDelegate = self
                interstitialViewController.modalPresentationStyle = interstitial.preferredModalPresentationStyle()
                presentingViewController.presentViewController(interstitialViewController, animated: true, completion: nil)
        }
        
        acknowledgeAlert(alert)
    }

    // TODO: don't send a request after Error alert
    private func acknowledgeAlert(alert: Alert) {
        if alert.alertType != .WebSocketError {
            AlertAcknowledgeOperation(alertID: alert.alertID).queue()
        }

        shownAlerts.append(alert)
        isShowingInterstital = true
    }

    private func addInterstitial(interstitial: UIViewController, toParent parent: UIViewController) {
        parent.view.addSubview(interstitial.view)
        interstitial.willMoveToParentViewController(parent)
        parent.addChildViewController(interstitial)
        interstitial.didMoveToParentViewController(parent)
    }
    
    // MARK: - AlertReceiver

    func receive(alert: Alert) {
        guard !registeredAlerts.contains(alert) && !shownAlerts.contains(alert) else {
            return
        }

        registeredAlerts.append(alert)

        if let interstitialListener = interstitialListener {
            interstitialListener.newInterstitialHasBeenRegistered()
        }
    }

    func receive(alerts: [Alert]) {
        for alert in alerts {
            receive(alert)
        }
    }
    
    // MARK: Interstitial
    
    func dismissInterstitial(interstitialViewController: UIViewController) {
        if interstitialViewController.presentingViewController != nil {
            interstitialViewController.dismissViewControllerAnimated(true, completion: nil)
        } else if interstitialViewController.parentViewController != nil {
            interstitialViewController.view.removeFromSuperview()
        }
        
        presentedInterstitial = nil
        isShowingInterstital = false
    }
    
    // MARK: Transition Delegate
        
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
