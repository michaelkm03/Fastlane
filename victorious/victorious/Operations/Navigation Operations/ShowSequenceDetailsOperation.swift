//
//  ShowSequenceDetailsOperation.swift
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
    
    init( originViewController: UIViewController, dependencyManager: VDependencyManager, sequence: VSequence) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.sequence = sequence
        super.init()
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


class ShowMemersOperation: NavigationOperation {
    
    private let dependencyManager: VDependencyManager
    private let originViewController: UIViewController
    private let sequence: VSequence
    
    init( originViewController: UIViewController, dependencyManager: VDependencyManager, sequence: VSequence) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.sequence = sequence
        super.init()
    }
    
    override func start() {
        super.start()
        self.beganExecuting()
        
        if let memeStream = dependencyManager.memeStreamForSequence(sequence) {
            originViewController.navigationController?.pushViewController(memeStream, animated: true)
        }
        
        self.finishedExecuting()
    }
    
}


class ShowRepostersOperation: NavigationOperation {
    
    private let dependencyManager: VDependencyManager
    private let originViewController: UIViewController
    private let sequence: VSequence
    private let presentationCompletion: (()->())?
    
    init( originViewController: UIViewController, dependencyManager: VDependencyManager, sequence: VSequence) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.sequence = sequence
        super.init()
    }
    
    override func start() {
        super.start()
        self.beganExecuting()
        
        if let vc: VReposterTableViewController = VReposterTableViewController(sequence: sequence, dependencyManager: dependencyManager) {
            originViewController.navigationController?.pushViewController(vc, animated: true)
        }
        
        self.finishedExecuting()
    }
    
}
