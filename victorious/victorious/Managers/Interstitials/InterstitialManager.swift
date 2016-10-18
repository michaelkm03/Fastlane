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
}

/// A singleton object for managing alerts received from the Victorious API and presenting appropriate
/// intestitial view controllers to the user upon receipt.
class InterstitialManager: NSObject, UIViewControllerTransitioningDelegate, InterstitialDelegate, AlertReceiver {
    
    var disabled: Bool = false
    
    /// Returns the interstitial manager singelton
    static let sharedInstance = InterstitialManager()
    
    var dependencyManager: VDependencyManager?
    
    var interstitialListener: InterstitialListener?
    
    fileprivate(set) var isShowingInterstital = false
    
    fileprivate var registeredAlerts = [Alert]()
    
    fileprivate var shownAlerts = [Alert]()
    
    fileprivate var presentedInterstitial: Interstitial?
    
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
    
    fileprivate func showInterstitial(with alert: Alert, onto presentingViewController: UIViewController) {
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
            case .achievement, .statusUpdate, .clientSideCreated:
                interstitialViewController.transitioningDelegate = self
                interstitialViewController.modalPresentationStyle = interstitial.preferredModalPresentationStyle()
                presentingViewController.present(interstitialViewController, animated: true)
        }

        acknowledgeAlert(alert)
    }

    fileprivate func acknowledgeAlert(_ alert: Alert) {
        switch alert.type {
            case .achievement, .statusUpdate, .toast:
                RequestOperation(request: AcknowledgeAlertRequest(alertID: alert.alertID)).queue()
            case .clientSideCreated, .reconnectingError:
                break
        }

        shownAlerts.append(alert)
        isShowingInterstital = true
    }

    fileprivate func addInterstitial(_ interstitial: UIViewController, toParent parent: UIViewController) {
        parent.view.addSubview(interstitial.view)
        interstitial.willMove(toParentViewController: parent)
        parent.addChildViewController(interstitial)
        interstitial.didMove(toParentViewController: parent)
    }

    // MARK: - AlertReceiver

    func receive(_ alert: Alert) {
        guard !registeredAlerts.contains(alert) && !shownAlerts.contains(alert) else {
            return
        }

        registeredAlerts.append(alert)

        if let interstitialListener = interstitialListener {
            interstitialListener.newInterstitialHasBeenRegistered()
        }
    }

    func receive(_ alerts: [Alert]) {
        for alert in alerts {
            receive(alert)
        }
    }
    
    // MARK: InterstitialDelegate

    /// Dismisses the interstitial on the screen at the moment if it's `Alert` is of the correct type.
    func dismissCurrentInterstitial(of alertType: AlertType) {
        guard let currentInterstitial = presentedInterstitial as? UIViewController , presentedInterstitial?.alert?.type == alertType else {
            return
        }
        dismissInterstitial(currentInterstitial)
    }
    
    func dismissInterstitial(_ interstitialViewController: UIViewController) {
        if interstitialViewController.parent != nil {
            interstitialViewController.willMove(toParentViewController: nil)
            interstitialViewController.view.removeFromSuperview()
            interstitialViewController.removeFromParentViewController()
        }
        else if interstitialViewController.presentingViewController != nil {
            interstitialViewController.dismiss(animated: true)
        }

        presentedInterstitial = nil
        isShowingInterstital = false
    }
    
    // MARK: Transition Delegate
        
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentedInterstitial?.presentationAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentedInterstitial?.dismissalAnimator()
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return presentedInterstitial?.presentationController(presented, presentingViewController: presenting)
    }
}
