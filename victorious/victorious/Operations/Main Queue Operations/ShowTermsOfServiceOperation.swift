//
//  ShowTermsOfServiceOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ShowTermsOfServiceOperation: BackgroundOperation {
    
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
        
        dispatch_async( dispatch_get_main_queue() ) {
            self.performNavigation()
        }
    }
    
    private func performNavigation() {
        guard let targetViewController = UIViewController.v_rootPresentationTargetViewController() else {
            assertionFailure("Failed to present view controller")
            return
        }
        let viewController = VTOSViewController.presentableTermsOfServiceViewController()
        targetViewController.presentViewController(viewController, animated: animated) {
            self.finishedExecuting()
        }
    }
}
