//
//  Scaffold.swift
//  victorious
//
//  Created by Jarod Long on 4/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

/// A protocol for scaffold view controllers that defines the common functionality between them.
protocol Scaffold: InterstitialListener {
    /// The scaffold's dependency manager.
    var dependencyManager: VDependencyManager { get }
    
    /// The coachmark manager associated with the scaffold. 
    var coachmarkManager: CoachmarkManager { get }
    
    /// The top-level navigation controller used by the scaffold.
    var mainNavigationController: UINavigationController { get }
    
    func navigate(to deeplinkURL: NSURL)
}

extension Scaffold where Self: UIViewController {
    // MARK: - Setup
    
    /// Performs setup common to all scaffolds. Expected to be called from `viewDidLoad`.
    func performCommonInitialSetup() {
        InterstitialManager.sharedInstance.interstitialListener = self
        definesPresentationContext = true
    }
    
    /// Performs first-launch setup. Expected to be called only once from the first invocation of `viewDidAppear`.
    func performSetup(onReady: (() -> Void)? = nil) {
        let pushNotificationOperation = RequestPushNotificationPermissionOperation()
        let tutorialOperation = ShowTutorialsOperation(originViewController: self, dependencyManager: dependencyManager)
        pushNotificationOperation.addDependency(tutorialOperation)
        
        tutorialOperation.queue()
        pushNotificationOperation.queue { _ in
            onReady?()
        }
    }
    
    // MARK: - Notifications
    
    /// Handles a change in logged-in status. Expected to be called from a handler of `kLoggedInChangedNotification`.
    func handleLoggedInStatusChange() {
        if VCurrentUser.user() == nil {
            ShowLoginOperation(originViewController: self, dependencyManager: dependencyManager, animated: true).queue()
        }
    }
    
    // MARK: - InterstitialListener

    func newInterstitialHasBeenRegistered() {
        // Don't stack interstitials on each other.
        if presentedViewController is Interstitial {
            return
        }

        if let presentedViewController = presentedViewController {
            InterstitialManager.sharedInstance.showNextInterstitial(onViewController: presentedViewController)
        } else {
            InterstitialManager.sharedInstance.showNextInterstitial(onViewController: self)
        }
    }
    
    func navigate(to deeplinkURL: NSURL) {
        let router = Router(originViewController: self.mainNavigationController, dependencyManager: dependencyManager)
        let destination = DeeplinkDestination(url: deeplinkURL)
        router.navigate(to: destination, from: nil)
    }
}
