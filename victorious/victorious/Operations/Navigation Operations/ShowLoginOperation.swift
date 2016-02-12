//
//  ShowLoginOperation.swift
//  victorious
//
//  Created by Michael Sena on 8/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class ShowLoginOperation: Operation {
    
    private weak var originViewController: UIViewController?
    private let dependencyManager: VDependencyManager
    private let context: VAuthorizationContext
    private let animated: Bool
    
    required init( originViewController: UIViewController, dependencyManager: VDependencyManager, context: VAuthorizationContext = .Default, animated: Bool = true) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.context = context
        self.animated = animated
        
        super.init()
        
        qualityOfService = .UserInteractive
    }
    
    // MARK: - Override
    
    override func start() {
        super.start()
        
        dispatch_async( dispatch_get_main_queue() ) {
            
            // Don't show login when running unit tests
            guard !self.cancelled && !VAutomation.shouldAlwaysShowLoginScreen() else {
                self.finishedExecuting()
                return
            }
            
            // Don't show login if the user is already logged in
            guard VCurrentUser.user() == nil else {
                self.finishedExecuting()
                return
            }
            
            self.beganExecuting()
            
            // User is not logged in, show login view
            guard let templateValue = self.dependencyManager.templateValueConformingToProtocol( VLoginRegistrationFlow.self,
                forKey: "loginAndRegistrationView"),
                let viewController = templateValue as? UIViewController,
                let loginFlow = templateValue as? VLoginRegistrationFlow else {
                    fatalError("Unable to find login view controller to present to user.")
            }
            
            loginFlow.onCompletionBlock = { authorized in
                
                // Dismiss on the next run cycle to give the UI initailziation code that we
                // happen to know is in the completion block of this operation a chance
                // to run first so that the configured tab bar is visible immediately
                // when the login view controller is dismissed.
                dispatch_after(0.0) {
                    self.originViewController?.dismissViewControllerAnimated(true, completion: nil)
                }
                
                self.finishedExecuting()
            }
            loginFlow.setAuthorizationContext?( self.context )
            
            self.originViewController?.presentViewController(viewController, animated: self.animated, completion: nil)
        }
    }
}
