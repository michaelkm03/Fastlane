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
    var isShowingInterstital = false
    var shouldRegisterInterstitials = true
    
    private let interstitialWindow: UIWindow
    
    override init() {
        interstitialWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
        interstitialWindow.alpha = 0
        interstitialWindow.hidden = true
        interstitialWindow.backgroundColor = UIColor.clearColor()
        interstitialWindow.windowLevel = UIWindowLevelStatusBar
    }
    
    private var registeredInterstitials = Set<Interstitial>()
    
    func registerInterstitials(interstitials: [Interstitial]) {
        
        if !shouldRegisterInterstitials {
            return
        }
        
        for interstitial in interstitials {
            if !registeredInterstitials.contains(interstitial) {
                registeredInterstitials.insert(interstitial)
            }
        }
        
        // Show most recent interstitial
        show(Array(registeredInterstitials).last)
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
                
                // Mark the rest of interstitials as seen
                for interstitial in registeredInterstitials {
                    VObjectManager.sharedManager().markInterstitialAsSeen(interstitial.remoteID, success: nil, failure: nil)
                }
                
                // Remove all interstitials
                registeredInterstitials.removeAll(keepCapacity: false)
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
                self.isShowingInterstital = false
        }
    }
}
