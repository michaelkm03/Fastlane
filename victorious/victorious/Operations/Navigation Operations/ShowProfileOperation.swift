//
//  ShowProfileOperation.swift
//  victorious
//
//  Created by Vincent Ho on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ShowProfileOperation: NavigationOperation {
    
    private let dependencyManager: VDependencyManager
    private let originViewController: UIViewController
    private let userId: Int
    
    init( originViewController: UIViewController, dependencyManager: VDependencyManager, userId: Int) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.userId = userId
        super.init()
    }
    
    override func start() {
        super.start()
        self.beganExecuting()
        
        guard let navigationViewController = originViewController.navigationController else {
            self.finishedExecuting()
            return
        }
        
        if let originViewControllerProfile = originViewController as? VUserProfileViewController where originViewControllerProfile.user.remoteId.integerValue == userId {
            self.finishedExecuting()
        }
        
        if let profileViewController = dependencyManager.userProfileViewControllerWithRemoteId(userId) {
            navigationViewController.pushViewController(profileViewController, animated: true)
        }
        
        self.finishedExecuting()
    }
}