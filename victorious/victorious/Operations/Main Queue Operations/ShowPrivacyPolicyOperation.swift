//
//  ShowPrivacyPolicyOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ShowPrivacyPolicyOperation: MainQueueOperation {
    
    private let dependencyManager: VDependencyManager
    private let animated: Bool
    
    required init( dependencyManager: VDependencyManager, animated: Bool = true) {
        self.dependencyManager = dependencyManager
        self.animated = animated
    }
    
    override func start() {
        
        guard !cancelled else {
            self.finishedExecuting()
            return
        }
        
        let viewController = VPrivacyPoliciesViewController.presentableTermsOfServiceViewControllerWithDependencyManager(dependencyManager)
        VRootViewController.sharedRootViewController()!.presentViewController(viewController, animated: animated) {
            self.finishedExecuting()
        }
    }
}
