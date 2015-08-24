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
    
    private let autoShowLoginKey = "showLoginOnStartup"
    let loginAuthorizedAction: VAuthorizedAction
    private let dependencyManager: VDependencyManager
    private let viewControllerToPresentFrom: UIViewController
    
    /// A Delegate to manage the showing/hiding of the loginViewController.
    var delegate: AutoShowLoginOperationDelegate?
    
    /// Initializes a new AutoShowLoginOperation with the provided parameters.
    ///
    /// :param: objectManager The object manager to use when creating an internal VAuthorizedAction. Will be used to dervie current login status.
    /// :param: dependencyManager The dependency manager to use for determinging whether or not to auto-show login based on `showLoginOnStartup` key. Also passed to the internal VAuthorizedAction.
    /// :param: viewControllerToPresentFrom A `UIViewController` to provide to VAuthorizedAction.
    ///
    /// :returns: An AutoShowLoginOperation.
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
        
        var shouldAutoShowLogin = dependencyManager.numberForKey(autoShowLoginKey)
        if shouldAutoShowLogin.boolValue
        {
            dispatch_async(dispatch_get_main_queue(), {
                var loginVC = self.loginAuthorizedAction.loginViewControllerWithContext(.Default,
                    withCompletion: { (success: Bool) in
                        self.delegate?.hideLoginViewController() {
                            self.finishedExecuting()
                        }
                    })
                self.delegate?.showLoginViewController(loginVC)
            })
        }
        else
        {
            finishedExecuting()
        }
    }
    
}
