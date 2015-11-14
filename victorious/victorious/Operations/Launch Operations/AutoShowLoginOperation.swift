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
    
    private let dependencyManager: VDependencyManager
    
    /// A Delegate to manage the showing/hiding of the loginViewController.
    weak var delegate: AutoShowLoginOperationDelegate?
    
    /// Initializes a new AutoShowLoginOperation with the provided parameters.
    ///
    /// - parameter dependencyManager: Passed to the internal VAuthorizedAction.
    /// - returns: An AutoShowLoginOperation.
    init(dependencyManager: VDependencyManager, delegate: AutoShowLoginOperationDelegate) {
        self.dependencyManager = dependencyManager
        self.delegate = delegate
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
            
            let dataStore = PersistentStore.mainContext
            if let currentUser = VUser.currentUser(inContext: dataStore) {
                
                // User is already logged in, proceed onward
                self.finishedExecuting()
                
                // FIXME:
               /* if currentUser.status != "complete" {
                    // User must complete his or her profile, show the create profile view
                    let viewController = VProfileCreateViewController.newWithDependencyManager(self.dependencyManager)
                    viewController.profile = currentUser
                    (viewController as VAuthorizationProvider).authorizedAction = { authorized in
                        self.delegate?.hideLoginViewController() {
                            self.finishedExecuting()
                        }
                    }
                    self.delegate?.showLoginViewController( viewController )
                }
                else {
                    // User is already logged in, proceed onward
                    self.finishedExecuting()
                }*/
            }
            else {
                // User is not logged in, show login view
                let viewController = self.dependencyManager.templateValueConformingToProtocol( VLoginRegistrationFlow.self,
                    forKey: "loginAndRegistrationView") as! VLoginRegistrationFlow
                viewController.setCompletionBlock(){ (finished) -> Void in
                    self.delegate?.hideLoginViewController() {
                        self.finishedExecuting()
                    }
                }
                viewController.setAuthorizationContext?( .Default ) // TODO: Get context
                self.delegate?.showLoginViewController( viewController as! UIViewController )
            }
        }
    }
}
