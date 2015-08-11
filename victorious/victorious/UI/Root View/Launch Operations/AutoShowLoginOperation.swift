//
//  AutoShowLoginOperation.swift
//  victorious
//
//  Created by Michael Sena on 8/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class AutoShowLoginOperation: NSOperation {
    
    let loginAuthorizedAction: VAuthorizedAction
    
    // MARK: Overrides
    
    init(objectManager: VObjectManager, dependencyManager: VDependencyManager, viewControllerToPresentFrom: UIViewController) {
        _executing = false
        _finished = false
        loginAuthorizedAction = VAuthorizedAction(objectManager: objectManager, dependencyManager: dependencyManager)
        
        super.init()
        
        dispatch_async(dispatch_get_main_queue(), {
            loginAuthorizedAction.prepareInViewController(viewControllerToPresentFrom, context: VAuthorizationContext.Default, completion: { (success: Bool) -> Void in
                self.onLoginComplete()
            })
        })
    }
    
    override func start() {
        super.start()
        executing = true
        finished = false
        
        println("starting")
    }
    
    // MARK: Internal
    
    private func onLoginComplete() {
        executing = false
        finished = true
    }
    
    // MARK: NSOperation Execution Properties
    
    private var _executing : Bool
    override var executing : Bool {
        get {return _executing }
        set {
            willChangeValueForKey("isExecuting")
            _executing = newValue
            didChangeValueForKey("isExecuting")
        }
    }
    
    private var _finished : Bool
    override var finished : Bool {
        get {return _finished }
        set {
            willChangeValueForKey("isFinished")
            _finished = newValue
            didChangeValueForKey("isFinished")
        }
    }
    
}
