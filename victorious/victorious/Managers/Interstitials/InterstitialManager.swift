//
//  InterstitialManager.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// A class that conforms to this protocol can be updated when interstitials are registered.
@objc protocol InterstitialListener {
    
    /// Called when a new interstitial is registered by the interstitial manager
    func newInterstitialHasBeenRegistered()
}

/// A singleton object for managing interstitial objects and presenting their
/// associated view controllers
class InterstitialManager: NSObject, UIViewControllerTransitioningDelegate, InterstitialViewControllerDelegate {
    
    /// Returns the interstitial manager singelton
    static let sharedInstance = InterstitialManager()
    
    /// The interstitial manager's dependency manager which it feeds to
    /// the interstitials in order to build their view controllers
    var dependencyManager: VDependencyManager?
    
    /// A listener that can be notified of interstitial events
    var interstitialListener: InterstitialListener?
    
    /// Whether or not the interstitial window is currently on screen
    private(set) var isShowingInterstital = false
    
    /// Whether or not the interstitial manager should register new interstitials
    var shouldRegisterInterstitials = true
    
    private var registeredInterstitials = [Interstitial]()
    
    private var shownInterstitials = [Interstitial]()
    
    private var presentedInterstitial: InterstitialViewController?
    
    /// Register an array of interstitials.
    func registerInterstitials(interstitials: [Interstitial]) {
        
        if !shouldRegisterInterstitials {
            return
        }
        
        for interstitial in interstitials where !registeredInterstitials.contains({ $0 == interstitial }) && !shownInterstitials.contains({ $0 == interstitial }) {
            registeredInterstitials.append(interstitial)
            if let interstitialListener = interstitialListener {
                interstitialListener.newInterstitialHasBeenRegistered()
            }
        }
    }
    
    /// Presents the next interstitial on the provided view controller modally.
    func displayNextInterstitialIfPossible(viewController: UIViewController) {
        if registeredInterstitials.count > 0 {
            show(registeredInterstitials.removeAtIndex(0), presentingViewController: viewController)
        }
    }
    
    private func show(interstitial: Interstitial?, presentingViewController: UIViewController) {
        
        if isShowingInterstital {
            return
        }
        
        if let interstitial = interstitial,
           let dependencyManager = dependencyManager,
           let viewController = interstitial.viewControllerToPresent(dependencyManager: dependencyManager) as? UIViewController,
           let conformingViewController = viewController as? InterstitialViewController {
                presentedInterstitial = conformingViewController
                conformingViewController.interstitialDelegate = self
                viewController.transitioningDelegate = self
                viewController.modalPresentationStyle = .Custom
                presentingViewController.presentViewController(viewController, animated: true, completion: nil)
                shownInterstitials.append(interstitial)
                isShowingInterstital = true
                
                // Mark this interstitial as seen
                VObjectManager.sharedManager().markInterstitialAsSeen(interstitial.remoteID, success: nil, failure: nil)
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
}

extension InterstitialManager {
    
    /// Registers a test "level" alert for testing interstitials
    func registerTestLevelUpAlert() {
        #if V_SHOW_TEST_ALERT_SETTINGS
        self.shouldRegisterInterstitials = false
        let params = ["type" : "levelUp", "params" : ["level" : ["number" : 5, "tier" : "Bronze", "name" : "Level 5"], "title" : "Congrats", "description" : "You won some new stuff", "icons" : ["http://i.imgur.com/ietHgk6.png"], "backgroundVideo" : "http://media-dev-public.s3-website-us-west-1.amazonaws.com/b918ccb92d5040f754e70187baf5a765/playlist.m3u8"]]
        VObjectManager.sharedManager().registerTestAlert(params, success: { (op, obj, resp) -> Void in
            self.shouldRegisterInterstitials = true
            }) { (op, err) -> Void in
                self.shouldRegisterInterstitials = true
        }
        #endif
    }
}
