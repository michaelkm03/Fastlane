//
//  ShowProfileOperation.swift
//  victorious
//
//  Created by Vincent Ho on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ShowProfileOperation: MainQueueOperation {
    
    private let dependencyManager: VDependencyManager
    private weak var originViewController: UIViewController?
    private let userId: Int
    
    init( originViewController: UIViewController,
          dependencyManager: VDependencyManager,
          userId: Int) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.userId = userId
    }
    
    override func start() {
        super.start()
        defer {
            finishedExecuting()
        }
        
        // Check if already showing the a user's profile
        if let originViewControllerProfile = originViewController as? VUserProfileViewController
            where originViewControllerProfile.user.remoteId.integerValue == userId {
            return
        }
        
        guard let profileViewController = dependencyManager.userProfileViewController(withRemoteID: userId),
            let originViewController = originViewController else {
                return
        }
        
        if let originViewController = originViewController as? UINavigationController {
            originViewController.pushViewController(profileViewController, animated: true)
        } else {
            originViewController.navigationController?.pushViewController(profileViewController, animated: true)
        }
    }
}
