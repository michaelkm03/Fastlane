//
//  ShowLoginOperation.swift
//  victorious
//
//  Created by Michael Sena on 8/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

final class ShowLoginOperation: AsyncOperation<Void> {
    private weak var originViewController: UIViewController?
    private let dependencyManager: VDependencyManager
    private let animated: Bool
    
    required init(
        originViewController: UIViewController,
        dependencyManager: VDependencyManager,
        animated: Bool = true
    ) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.animated = animated
    }
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(_ finish: @escaping (_ result: OperationResult<Void>) -> Void) {
        
        // Don't show login if the user is already logged in
        guard VCurrentUser.user == nil else {
            finish(.success())
            return
        }
        
        // User is not logged in, show login view
        guard
            let templateValue = self.dependencyManager.templateValueConforming(to: VLoginRegistrationFlow.self, forKey: "loginAndRegistrationView"),
            let viewController = templateValue as? UIViewController,
            let loginFlow = templateValue as? VLoginRegistrationFlow
        else {
            let error = NSError(domain: "ShowLoginOperation", code: -1, userInfo: nil)
            finish(.failure(error))
            return
        }
        
        let originViewController = self.originViewController
        
        loginFlow.onCompletionBlock = { didSucceed in
            finish(.success())
            
            guard didSucceed else {
                return
            }
            
            // Dismiss on the next run cycle to give the UI initailziation code (that we
            // happen to know is in the completion block of this operation) a chance
            // to run first so that the configured tab bar is visible immediately
            // when the login view controller is dismissed.
            dispatch_after(0.0) {
                originViewController?.dismiss(animated: true)
            }
        }
        
        originViewController?.present(viewController, animated: animated)
    }
}
