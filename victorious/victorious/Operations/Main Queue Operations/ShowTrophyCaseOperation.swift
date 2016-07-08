//
//  ShowTrophyCaseOperation.swift
//  victorious
//
//  Created by Tian Lan on 3/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ShowTrophyCaseOperation: MainQueueOperation {
    
    private let originViewController: UIViewController
    private let dependencyManager: VDependencyManager
    
    required init( originViewController: UIViewController, dependencyManager: VDependencyManager) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        
        super.init()
        
        if
            let currentUserID = VCurrentUser.user()?.remoteId.integerValue,
            let apiPath = dependencyManager.networkResources?.userFetchAPIPath,
            let userInfoOperation = UserInfoOperation(userID: currentUserID, apiPath: apiPath)
        {
            userInfoOperation.before(self).queue()
        }
    }
    
    override func start() {
        beganExecuting()
        
        guard let trophyCaseViewController = dependencyManager.trophyCaseViewController() else {
            finishedExecuting()
            return
        }
        originViewController.navigationController?.pushViewController(trophyCaseViewController, animated: true)
        finishedExecuting()
    }
}

extension VDependencyManager {
    func trophyCaseViewController() -> TrophyCaseViewController? {
        guard let trophyCaseViewController = templateValueOfType(TrophyCaseViewController.self, forKey: VDependencyManager.trophyCaseScreenKey) as? TrophyCaseViewController else {
            return nil
        }
        return trophyCaseViewController
    }
    
    
}
