//
//  ShowNewProfileOperation.swift
//  victorious
//
//  Created by Vincent Ho on 5/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ShowNewProfileOperation: MainQueueOperation {
    
    private let dependencyManager: VDependencyManager
    private let animated: Bool
    private weak var originViewController: UIViewController?
    private var user: VUser
    
    init( originViewController: UIViewController,
          dependencyManager: VDependencyManager,
          user: VUser,
          animated: Bool = true) {
        
        self.dependencyManager = dependencyManager
        self.originViewController = originViewController
        self.animated = animated
        self.user = user
    }
    
    override func start() {
        
        guard let childDependencyManager = dependencyManager.childDependencyForKey("userProfileView")
            where !self.cancelled else {
                finishedExecuting()
                return
        }
        defer {
            finishedExecuting()
        }
        
        let header = VNewProfileHeaderView.newWithDependencyManager(childDependencyManager)
        
        let closeUpViewController = GridStreamViewController<VNewProfileHeaderView>.newWithDependencyManager(
            childDependencyManager,
            header: header,
            content: user,
            streamAPIPath: childDependencyManager.streamAPIPath(for: user)!
        )
        originViewController?.navigationController?.pushViewController(closeUpViewController, animated: animated)
    }
    
}

private extension VDependencyManager {
    func streamAPIPath(for user: VUser) -> String? {
        return stringForKey("streamURL")?.stringByReplacingOccurrencesOfString("%%USER_ID%%", withString: "\(user.remoteId.integerValue)")
    }
}
