//
//  ShowVIPForumOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ShowVIPForumOperation: NavigationOperation {
    
    private weak var originViewController: UIViewController?
    private let dependencyManager: VDependencyManager
    private let animated: Bool
    
    required init( originViewController: UIViewController, dependencyManager: VDependencyManager, animated: Bool = true) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.animated = animated
    }
    
    override func start() {
        super.start()
        beganExecuting()
        
        let chatViewController = ChatViewController.newWithDependencyManager(dependencyManager)
        let navigationController = UINavigationController(rootViewController: chatViewController)
        originViewController?.presentViewController(navigationController, animated: animated) {
            self.finishedExecuting()
        }
    }
}
