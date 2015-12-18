//
//  InterstitialManager.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// A class that conforms to this protocol can be updated when interstitials are registered.
@objc protocol InterstitialListener {
    
    /// Called when a new interstitial is registered by the interstitial manager
    func newInterstitialHasBeenRegistered()
}

/// A singleton object for managing interstitial objects and presenting their
/// associated view controllers
class InterstitialManager: NSObject, UIViewControllerTransitioningDelegate, InterstitialViewControllerDelegate {
    
    /// Whether or not the object manager checks each response for alerts
    var shouldRegisterAlerts: Bool = true
    
    /// Returns the interstitial manager singelton
    static let sharedInstance = InterstitialManager()
    
    /// The interstitial manager's dependency manager which it feeds to
    /// the interstitials in order to build their view controllers
    var dependencyManager: VDependencyManager?
    
    /// A listener that can be notified of interstitial events
    var interstitialListener: InterstitialListener?
    
    /// Whether or not the interstitial window is currently on screen
    private(set) var isShowingInterstital = false
    
    private var registeredAlerts = [Alert]()
    
    private var shownAlerts = [Alert]()
    
    private var presentedInterstitial: InterstitialViewController?
    
    /// Register an array of alerts to show as interstitials.
    func registerAlerts(alerts: [Alert]) {
        for alert in alerts where !registeredAlerts.contains({ $0 == alert }) && !shownAlerts.contains({ $0 == alert }) {
            registeredAlerts.append(alert)
            if let interstitialListener = interstitialListener {
                interstitialListener.newInterstitialHasBeenRegistered()
            }
        }
    }
    
    /// Presents the next interstitial on the provided view controller modally.
    func displayNextInterstitialIfPossible(viewController: UIViewController) {
        if !registeredAlerts.isEmpty {
            showInterstitial( alert: registeredAlerts.removeAtIndex(0), presentingViewController: viewController)
        }
    }
    
    /// Removes all registered interstitials
    func clearAllRegisteredAlerts() {
        registeredAlerts.removeAll()
    }
    
    private func showInterstitial( alert alert: Alert, presentingViewController: UIViewController) {
        
        if isShowingInterstital {
            return
        }
        
        if let dependencyManager = dependencyManager,
            let viewController = alert.viewControllerToPresent(dependencyManager: dependencyManager) as? UIViewController,
            let conformingViewController = viewController as? InterstitialViewController {
                
                presentedInterstitial = conformingViewController
                conformingViewController.interstitialDelegate = self
                viewController.transitioningDelegate = self
                viewController.modalPresentationStyle = conformingViewController.preferredModalPresentationStyle()
                presentingViewController.presentViewController(viewController, animated: true, completion: nil)
                shownAlerts.append( alert )
                isShowingInterstital = true
                
                AcknowledgeAlertOperation( alertID: Int64(alert.alertID) ).queue()
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
    
    /// Registers a test "level" alert for testing interstitials
    func registerTestLevelUpAlert() {
        #if V_SHOW_TEST_ALERT_SETTINGS
            self.shouldRegisterAlerts = false
            let params = ["type" : "levelUp", "params" : ["user" : ["fanloyalty" : ["level" : 5, "tier" : "Bronze", "name" : "Level 5", "progress" : 70]], "title" : "Congrats", "description" : "You won some new stuff", "icons" : ["http://i.imgur.com/ietHgk6.png"], "backgroundVideo" : "http://media-dev-public.s3-website-us-west-1.amazonaws.com/b918ccb92d5040f754e70187baf5a765/playlist.m3u8"]]
            
            if let addtionalParameters = params["params"] as? [String : AnyObject],
                let type = params["type"] as? String {
                    CreateAlertOperation(type: type, addtionalParameters: addtionalParameters).queue() { error in
                        self.shouldRegisterAlerts = true
                    }
            }
        #endif
    }
    
    /// Registers a test "achievement" alert for testing interstitials
    func registerTestAchievementAlert() {
        #if V_SHOW_TEST_ALERT_SETTINGS
            self.shouldRegisterAlerts = false
            let params = ["type" : "achievement", "params" : ["user" : ["fanloyalty" : ["level" : 5, "tier" : "Bronze", "name" : "Level 5", "progress" : 70]], "title" : "Congrats", "description" : "Thanks for creating your first text post!", "icons" : ["http://i.imgur.com/ietHgk6.png"]]]
            
            if let addtionalParameters = params["params"] as? [String : AnyObject],
                let type = params["type"] as? String {
                    CreateAlertOperation(type: type, addtionalParameters: addtionalParameters).queue() { error in
                        self.shouldRegisterAlerts = true
                    }
            }
            
        #endif
    }
}
