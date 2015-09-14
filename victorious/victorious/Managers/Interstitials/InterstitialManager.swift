//
//  InterstitialManager.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// A singleton object for managing interstitial objects and presenting their
/// associated view controllers
class InterstitialManager: NSObject, InterstitialViewControllerDelegate {
    
    /// Returns the interstitial manager singelton
    static let sharedInstance = InterstitialManager()
    
    /// The interstitial manager's dependency manager which it feeds to
    /// the interstitials in order to build their view controllers
    var dependencyManager: VDependencyManager?
    
    /// Whether or not the interstitial window is currently on screen
    private(set) var isShowingInterstital = false
    
    /// Whether or not the interstitial manager should register new interstitials
    var shouldRegisterInterstitials = true
    
    private let interstitialWindow: UIWindow
    
    override init() {
        interstitialWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
        interstitialWindow.alpha = 0
        interstitialWindow.hidden = true
        interstitialWindow.backgroundColor = UIColor.clearColor()
        // Shows over keyboard and status bar
        interstitialWindow.windowLevel = UIWindowLevelAlert
    }
    
    private var registeredInterstitials = [Interstitial]()
    
    /// Register an array of interstitials and start showing them in the order that they were received.
    func registerInterstitials(interstitials: [Interstitial]) {
        
        if !shouldRegisterInterstitials {
            return
        }
        
        for interstitial in interstitials {
            if !contains(registeredInterstitials, interstitial) {
                // Set the dependency manager
                if let dependencyManager = dependencyManager {
                    interstitial.dependencyManager = dependencyManager
                    registeredInterstitials.append(interstitial)
                }
            }
        }
        
        // Show first interstitial
        displayNextInterstitial()
    }
    
    private func displayNextInterstitial() {
        if registeredInterstitials.count > 0 {
            // Show most recent interstitial
            show(registeredInterstitials.removeAtIndex(0))
        }
    }
    
    private func show(interstitial: Interstitial?) {
        
        if isShowingInterstital {
            return
        }
        
        if let interstitial = interstitial,
            viewController = interstitial.viewControllerToPresent() as? UIViewController,
            conformingViewController =  viewController as? InterstitialViewController {
                
                conformingViewController.interstitialDelegate = self
                interstitialWindow.rootViewController = viewController
                isShowingInterstital = true
                animateWindowIn()
                
                // Mark this interstitial as seen
                VObjectManager.sharedManager().markInterstitialAsSeen(interstitial.remoteID, success: nil, failure: nil)
        }
    }
    
    /// MARK: InterstitialViewController
    
    func dismissInterstitial() {
        animateWindowOut() {
            self.displayNextInterstitial()
        }
    }
    
    /// MARK: Helpers
    
    private func animateWindowIn() {
        interstitialWindow.hidden = false
        interstitialWindow.makeKeyAndVisible()
        if let interstitialViewController = interstitialWindow.rootViewController as? InterstitialViewController {
            UIView.animateWithDuration(interstitialViewController.presentationDuration(), animations: { () -> Void in
                self.interstitialWindow.alpha = 1
            })
        }
    }
    
    private func animateWindowOut(closure:(()->())?) {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.interstitialWindow.alpha = 0
            }) { (completed) -> Void in
                self.interstitialWindow.rootViewController = nil
                self.interstitialWindow.hidden = true
                self.interstitialWindow.resignKeyWindow()
                self.isShowingInterstital = false
                if let closure = closure {
                    closure()
                }
        }
    }
}
