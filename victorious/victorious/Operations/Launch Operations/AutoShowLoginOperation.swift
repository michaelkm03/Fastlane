//
//  AutoShowLoginOperation.swift
//  victorious
//
//  Created by Michael Sena on 8/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// A delegate for the AutoShowLoginOperation. Conformers should be able to
/// show/hide the given loginViewController. Either through containment or presentation.
@objc protocol AutoShowLoginOperationDelegate {
    
    /// Informs the delegate that the AutoShowLoginOperation now needs it's loginVC to be shown.
    func showLoginViewController(loginViewController: UIViewController)
    
    /// Informs the delegate that the loginViewController passed above should be hidden. This will always be called after `showLoginViewController`
    func hideLoginViewController(completion: () -> Void)
}

/// An `Operation` subclass for auto-showing login on startup.
class AutoShowLoginOperation: Operation {
    
    let loginAuthorizedAction: VAuthorizedAction
    private let dependencyManager: VDependencyManager
    private let viewControllerToPresentFrom: UIViewController
    
    /// A Delegate to manage the showing/hiding of the loginViewController.
    weak var delegate: AutoShowLoginOperationDelegate?
    
    /// Initializes a new AutoShowLoginOperation with the provided parameters.
    ///
    /// - parameter objectManager: The object manager to use when creating an internal VAuthorizedAction. Will be used to dervie current login status.
    /// - parameter dependencyManager: Passed to the internal VAuthorizedAction.
    /// - parameter viewControllerToPresentFrom: A `UIViewController` to provide to VAuthorizedAction.
    ///
    /// - returns: An AutoShowLoginOperation.
    init(objectManager: VObjectManager, dependencyManager: VDependencyManager, viewControllerToPresentFrom: UIViewController) {
        self.dependencyManager = dependencyManager
        self.viewControllerToPresentFrom = viewControllerToPresentFrom
        loginAuthorizedAction = VAuthorizedAction(objectManager: objectManager, dependencyManager: dependencyManager)
        
        super.init()
        
        qualityOfService = .UserInteractive
    }
    
    // MARK: - Override
    
    override func start() {
        super.start()
        
        if cancelled {
            finishedExecuting()
            return
        }
        
        beganExecuting()
        
        dispatch_async(dispatch_get_main_queue()) {
            
            let loginVC = self.loginAuthorizedAction.loginViewControllerWithContext(.Default) { success in
                self.delegate?.hideLoginViewController() {
                    self.finishedExecuting()
                }
            }
            
            let appTimingTracker = DefaultTimingTracker.sharedInstance()
            
            if let loginVC = loginVC {
                self.delegate?.showLoginViewController(loginVC)
                
                // The following event will only be measured when auto login will be presented
                appTimingTracker.endEvent(type: VAppTimingEventTypeShowRegistration)
                
            } else {
                // If the loginVC is nil we should not show and just finish up
                self.finishedExecuting()
                
                // Reset this event, since it's only valid when the login view will be presented
                appTimingTracker.resetEvent(type: VAppTimingEventTypeShowRegistration)
            }
        }
    }
    
}
