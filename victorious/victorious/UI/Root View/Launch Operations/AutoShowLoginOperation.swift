//
//  AutoShowLoginOperation.swift
//  victorious
//
//  Created by Michael Sena on 8/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// An `NSOperation` subclass for auto-showing login on startup.
class AutoShowLoginOperation: NSOperation {
    
    private let autoShowLoginKey = "showLoginOnStartup"
    
    let loginAuthorizedAction: VAuthorizedAction
    private let dependencyManager: VDependencyManager
    private let viewControllerToPresentFrom: UIViewController
    private var _executing : Bool
    private var _finished : Bool
    
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
        _executing = false
        _finished = false
        self.dependencyManager = dependencyManager
        self.viewControllerToPresentFrom = viewControllerToPresentFrom
        loginAuthorizedAction = VAuthorizedAction(objectManager: objectManager, dependencyManager: dependencyManager)
        
        super.init()
    }
    
    // MARK: - Override
    
    override func start() {
        super.start()
        
        if cancelled {
            executing = false
            finished = true
            return
        }
        
        executing = true
        finished = false
        
        var shouldAutoShowLogin = dependencyManager.numberForKey(autoShowLoginKey)
        if shouldAutoShowLogin.boolValue
        {
            dispatch_async(dispatch_get_main_queue(), {
                loginAuthorizedAction.prepareInViewController(viewControllerToPresentFrom,
                    context: VAuthorizationContext.Default,
                    completion: { (success: Bool) -> Void in
                    self.onLoginComplete()
                })
            })
        }
        else
        {
            executing = false
            finished = true
        }
    }
    
    // MARK: - Internal
    
    private func onLoginComplete() {
        executing = false
        finished = true
    }
    
    // MARK: - KVO-able NSNotification State
    
    override var executing : Bool {
        get {return _executing }
        set {
            willChangeValueForKey("isExecuting")
            _executing = newValue
            didChangeValueForKey("isExecuting")
        }
    }
    
    override var finished : Bool {
        get {return _finished }
        set {
            willChangeValueForKey("isFinished")
            _finished = newValue
            didChangeValueForKey("isFinished")
        }
    }
    
    
}
