//
//  ShowLoginOperation.swift
//  victorious
//
//  Created by Michael Sena on 8/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class ShowLoginOperation: Operation {
    
    private let originViewController: UIViewController
    private let dependencyManager: VDependencyManager
    private let context: VAuthorizationContext
    
    required init( originViewController: UIViewController, dependencyManager: VDependencyManager, context: VAuthorizationContext = .Default) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.context = context
        
        super.init()
        
        qualityOfService = .UserInteractive
    }
    
    // MARK: - Override
    
    override func start() {
        super.start()
        
        dispatch_async( dispatch_get_main_queue() ) {
            
            guard !self.cancelled && !VAutomation.shouldAlwaysShowLoginScreen() else {
                self.finishedExecuting()
                return
            }
            
            self.beganExecuting()
            
            if VUser.currentUser() != nil {
                // User is already logged in, proceed onward
                self.finishedExecuting()
            }
            else {
                // User is not logged in, show login view
                let viewController = self.dependencyManager.templateValueConformingToProtocol( VLoginRegistrationFlow.self,
                    forKey: "loginAndRegistrationView") as! VLoginRegistrationFlow
                viewController.onCompletionBlock = { (finished) -> Void in
                    self.originViewController.dismissViewControllerAnimated(true) {
                        self.finishedExecuting()
                    }
                }
                viewController.setAuthorizationContext?( self.context )
                self.originViewController.presentViewController( viewController as! UIViewController, animated: true, completion: nil)
            }
        }
    }
}
