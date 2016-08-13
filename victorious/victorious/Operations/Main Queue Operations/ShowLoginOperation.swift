//
//  ShowLoginOperation.swift
//  victorious
//
//  Created by Michael Sena on 8/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class ShowLoginOperation: AsyncOperation<Void> {
    private weak var originViewController: UIViewController?
    private let dependencyManager: VDependencyManager
    private let context: VAuthorizationContext
    private let animated: Bool
    private let loginCompletion: (()->())?
    
    required init(
        originViewController: UIViewController,
        dependencyManager: VDependencyManager,
        context: VAuthorizationContext = .Default,
        animated: Bool = true,
        loginCompletion: (()->())? = nil
    ) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.context = context
        self.animated = animated
        self.loginCompletion = loginCompletion
    }
    
    override var executionQueue: NSOperationQueue {
        return .mainQueue()
    }
    
    override func execute(finish: (result: OperationResult<Void>) -> Void) {
        
        // Don't show login if the user is already logged in
        guard VCurrentUser.user() == nil else {
            self.loginCompletion?()
            finish(result: .cancelled)
            return
        }
        
        // User is not logged in, show login view
        guard
            let templateValue = self.dependencyManager.templateValueConformingToProtocol(VLoginRegistrationFlow.self, forKey: "loginAndRegistrationView"),
            let viewController = templateValue as? UIViewController,
            let loginFlow = templateValue as? VLoginRegistrationFlow
        else {
            self.loginCompletion?()
            finish(result: .cancelled)
            return
        }
        
        let originViewController = self.originViewController
        let loginCompletion = self.loginCompletion
        loginFlow.onCompletionBlock = { didSucceed in
            loginCompletion?()
            
            guard didSucceed else {
                return
            }
            
            // Dismiss on the next run cycle to give the UI initailziation code (that we
            // happen to know is in the completion block of this operation) a chance
            // to run first so that the configured tab bar is visible immediately
            // when the login view controller is dismissed.
            dispatch_after(0.0) {
                originViewController?.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        loginFlow.setAuthorizationContext?( self.context )
        originViewController?.presentViewController(viewController, animated: animated) {
            finish(result: .success())
        }
    }
}
