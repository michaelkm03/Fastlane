//
//  AutoShowLoginOperation.swift
//  victorious
//
//  Created by Michael Sena on 8/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// An `Operation` subclass for auto-showing login on startup.
class AutoShowLoginOperation: Operation {
    
    private let autoShowLoginKey = "showLoginOnStartup"
    
    let loginAuthorizedAction: VAuthorizedAction
    private let dependencyManager: VDependencyManager
    private let viewControllerToPresentFrom: UIViewController
    
    ///
    ///    Initializes a new AutoShowLoginOperation with the provided parameters.
    ///
    ///    :param: objectManager The object manager to use when creating an internal VAuthorizedAction. Will be used to dervie current login status.
    ///    :param: dependencyManager The dependency manager to use for determinging whether or not to auto-show login based on `showLoginOnStartup` key. Also passed to the internal VAuthorizedAction.
    ///    :param: viewControllerToPresentFrom A `UIViewController` to provide to VAuthorizedAction.
    ///
    ///    :returns: An AutoShowLoginOperation.
    ///
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
                loginAuthorizedAction.prepareInViewController(viewControllerToPresentFrom,
                    context: VAuthorizationContext.Default,
                    completion: { (success: Bool) -> Void in
                    self.finishedExecuting()
                })
            })
        }
        else
        {
            finishedExecuting()
        }
    }
    
}
