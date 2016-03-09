//
//  ShowCommentsOperation.swift
//  victorious
//
//  Created by Vincent Ho on 3/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ShowCommentsOperation: NavigationOperation {
    
    private let dependencyManager: VDependencyManager
    private let originViewController: UIViewController
    private let sequence: VSequence
    
    init( originViewController: UIViewController, dependencyManager: VDependencyManager, sequence: VSequence) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.sequence = sequence
    }
    
    override func start() {
        super.start()
        self.beganExecuting()
        
        guard let navigationViewController = originViewController.navigationController else {
            assertionFailure("\(self.dynamicType) requires a navigation controller.")
            return
        }
        
        guard let commentsViewController: CommentsViewController = dependencyManager.commentsViewController(sequence) else {
            return
        }
        
        navigationViewController.pushViewController(commentsViewController, animated: true)
        self.finishedExecuting()
    }
    
}