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
    private weak var originViewController: UIViewController?
    
    required init( originViewController: UIViewController, dependencyManager: VDependencyManager, animated: Bool = true) {
        self.dependencyManager = dependencyManager
        self.originViewController = originViewController
        self.animated = animated
    }
    
    override func start() {
        
        guard !self.cancelled else {
            finishedExecuting()
            return
        }
        
        let templateValue = dependencyManager.templateValueOfType(ForumViewController.self, forKey: "forum")
        guard let viewController = templateValue as? ForumViewController else {
            finishedExecuting()
            return
        }
        
        let navigationController = UINavigationController(rootViewController: viewController)
        originViewController?.presentViewController(navigationController, animated: animated) {
            (self.dependencyManager.scaffoldViewController() as? VTabScaffoldViewController)?.setSelectedMenuItemAtIndex(0)
            self.finishedExecuting()
        }
    }
}
