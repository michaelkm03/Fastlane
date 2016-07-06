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
    /// A callback to let the implementer know that a new Alert has been registered.
    /// The receiver can then when it's ready call `showNextInterstitial` on `InterstitialManager`.
    func newInterstitialHasBeenRegistered()

    /// Dismisses the current interstitial on screen with the specified alert type.
    func dismissCurrentInterstitial(of alertType: AlertType)
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
    
    /// Removes all registered interstitials.
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
        
        switch alert.type {
            case .toast, .reconnectingError:
                addInterstitial(interstitialViewController, toParent: presentingViewController)
            case .achievement, .levelUp, .statusUpdate, .clientSideCreated:
                interstitialViewController.transitioningDelegate = self
                interstitialViewController.modalPresentationStyle = interstitial.preferredModalPresentationStyle()
                presentingViewController.presentViewController(interstitialViewController, animated: true, completion: nil)
        }

        acknowledgeAlert(alert)
    }

    private func acknowledgeAlert(alert: Alert) {
        switch alert.type {
            case .achievement, .levelUp, .statusUpdate, .toast:
                AlertAcknowledgeOperation(alertID: alert.alertID).queue()
            default:
                break
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

    /// Dismisses the interstitial on the screen at the moment if it's `Alert` is of the correct type.
    func dismissCurrentInterstitial(of alertType: AlertType) {
        guard let currentInterstitial = presentedInterstitial as? UIViewController where presentedInterstitial?.alert?.type == alertType else {
            return
        }
        dismissInterstitial(currentInterstitial)
    }
    
    func dismissInterstitial(interstitialViewController: UIViewController) {
        if interstitialViewController.parentViewController != nil {
            interstitialViewController.willMoveToParentViewController(nil)
            interstitialViewController.view.removeFromSuperview()
            interstitialViewController.removeFromParentViewController()
        }
        else if interstitialViewController.presentingViewController != nil {
            interstitialViewController.dismissViewControllerAnimated(true, completion: nil)
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
