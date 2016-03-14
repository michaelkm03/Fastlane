//
//  ShowForumOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ShowForumOperation: MainQueueOperation {
    
    private let dependencyManager: VDependencyManager
    private let animated: Bool
    
    required init( dependencyManager: VDependencyManager, animated: Bool = true) {
        self.dependencyManager = dependencyManager
        self.animated = animated
    }
    
    override func start() {
        super.start()
        
        guard !self.cancelled else {
            self.finishedExecuting()
            return
        }
        
        let templateValue = dependencyManager.templateValueOfType(ForumViewController.self, forKey:"forum")
        guard let viewController = templateValue as? ForumViewController,
            let originViewController = VRootViewController.sharedRootViewController() else {
                finishedExecuting()
                return
        }
        
        originViewController.presentViewController(viewController, animated: animated) {
            self.dependencyManager.scaffoldViewController()?.setSelectedMenuItemAtIndex(0)
            self.finishedExecuting()
        }
    }
}
