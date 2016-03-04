//
//  ShowLikersOperation.swift
//  victorious
//
//  Created by Vincent Ho on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ShowLikersOperation: NavigationOperation {
    
    private let dependencyManager: VDependencyManager
    private let originViewController: UIViewController
    private let sequence: VSequence
    
    required init( originViewController: UIViewController, dependencyManager: VDependencyManager, sequence: VSequence) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.sequence = sequence
    }
    
    override func start() {
        super.start()
        self.beganExecuting()
        
        let childDependencyManager = dependencyManager.childDependencyManagerWithAddedConfiguration([:])
        let usersViewController = VUsersViewController(dependencyManager: childDependencyManager)
        
        usersViewController.title = NSLocalizedString("LikersTitle", comment: "")
        usersViewController.usersDataSource = VLikersDataSource(sequence: sequence)
        usersViewController.usersViewContext = VUsersViewContext.Likers
        
        originViewController.navigationController?.pushViewController(usersViewController, animated: true)
        
        self.finishedExecuting()
    }
}
