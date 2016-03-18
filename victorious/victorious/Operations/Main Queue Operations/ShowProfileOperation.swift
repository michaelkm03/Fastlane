//
//  ShowProfileOperation.swift
//  victorious
//
//  Created by Vincent Ho on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ShowProfileOperation: BackgroundOperation {
    
    private let dependencyManager: VDependencyManager
    private let originViewController: UIViewController
    private let userId: Int
    
    init( originViewController: UIViewController, dependencyManager: VDependencyManager, userId: Int) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.userId = userId
    }
    
    override func start() {
        super.start()
        beganExecuting()
        
        dispatch_async(dispatch_get_main_queue()) {
            self.performNavigation()
        }
    }
    
    private func performNavigation() {
        guard let navigationViewController = originViewController.v_navigationController() else {
            assertionFailure("\(self.dynamicType) requires a VNavigation controller.")
            return
        }
        
        if let originViewControllerProfile = originViewController as? VUserProfileViewController
            where originViewControllerProfile.user.remoteId.integerValue == userId {
                finishedExecuting()
                return
        }
        
        if let profileViewController = dependencyManager.userProfileViewControllerWithRemoteId(userId) {
            navigationViewController.innerNavigationController.pushViewController(profileViewController, animated: true)
        }
        
        finishedExecuting()
    }
}
