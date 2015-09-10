//
//  InterstitialManager.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

protocol InterstitialViewController: class {
    weak var interstitialDelegate: InterstitialViewControllerControl? { get set }
}

protocol InterstitialViewControllerControl: class {
    func dismissInterstitial()
}

class InterstitialManager: NSObject, InterstitialViewControllerControl {
    
    static let sharedInstance = InterstitialManager()
    var shouldRegisterAlerts = true
    
    private let interstitialWindow: UIWindow
    private var currentlyShowingInterstitial: Interstitial?
    
    override init() {
        interstitialWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
        interstitialWindow.alpha = 0
        interstitialWindow.hidden = true
        interstitialWindow.backgroundColor = UIColor.clearColor()
        interstitialWindow.windowLevel = UIWindowLevelStatusBar
        
        
    }
    
    private var registeredInterstitials = Set<Interstitial>()
    
    func registerInterstitials(interstitials: [Interstitial]) {
        
        if !shouldRegisterAlerts {
            return
        }
        
        for interstitial in interstitials {
            if !registeredInterstitials.contains(interstitial) {
                registeredInterstitials.insert(interstitial)
                show(interstitial)
            }
        }
    }
    
    private func show(interstitial: Interstitial) {
        
        if currentlyShowingInterstitial != nil {
            return
        }
        
        if let viewController = interstitial.viewControllerToPresent() as? UIViewController,
            conformingViewController =  viewController as? InterstitialViewController {
                conformingViewController.interstitialDelegate = self
                interstitialWindow.rootViewController = viewController
                currentlyShowingInterstitial = interstitial
                animateWindowIn()
                VObjectManager.sharedManager().markInterstitialAsSeen(interstitial.remoteID, success: nil, failure: nil)
        }
    }
    
    /// MARK: InterstitialViewController
    
    func dismissInterstitial() {
        animateWindowOut()
    }
    
    /// MARK: Helpers
    
    func animateWindowIn() {
        interstitialWindow.hidden = false
        interstitialWindow.makeKeyAndVisible()
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.interstitialWindow.alpha = 1
        })
    }
    
    func animateWindowOut() {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.interstitialWindow.alpha = 0
            }) { (completed) -> Void in
                self.interstitialWindow.rootViewController = nil
                self.interstitialWindow.hidden = true
                self.interstitialWindow.resignKeyWindow()
                
                if let showingInterstitial = self.currentlyShowingInterstitial {
                    self.registeredInterstitials.remove(showingInterstitial)
                    self.currentlyShowingInterstitial = nil
                }
        }
    }
}
