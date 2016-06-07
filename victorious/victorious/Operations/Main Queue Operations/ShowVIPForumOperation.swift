//
//  ShowVIPForumOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 6/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ShowVIPForumOperation: MainQueueOperation {
    private let dependencyManager: VDependencyManager
    private let animated: Bool
    
    required init(dependencyManager: VDependencyManager, animated: Bool = true) {
        self.dependencyManager = dependencyManager
        self.animated = animated
    }
    
    override func start() {
        guard !cancelled else {
            finishedExecuting()
            return
        }
        
        guard let viewController = dependencyManager.templateValueOfType(ForumViewController.self, forKey: "vipForum") as? ForumViewController else {
            finishedExecuting()
            return
        }
        
        let forumNavigationController = UINavigationController(rootViewController: viewController)
        dependencyManager.scaffoldViewController()?.presentViewController(forumNavigationController, animated: animated) {
            self.finishedExecuting()
        }
    }
}
