//
//  ShowSequenceDetailsOperation.swift
//  victorious
//
//  Created by Vincent Ho on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

enum SequenceDetailType {
    case Memers
    case Likers
    case Reposters
}

class ShowSequenceDetailsOperation: NavigationOperation {
    
    private let dependencyManager: VDependencyManager
    private let originViewController: UIViewController
    private let sequence: VSequence
    private let presentationCompletion: (()->())?
    private let detailType: SequenceDetailType
    
    init( originViewController: UIViewController, dependencyManager: VDependencyManager, sequence: VSequence, detailType: SequenceDetailType, presentationCompletion: (()->())? ) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.sequence = sequence
        self.detailType = detailType
        self.presentationCompletion = presentationCompletion
        super.init()
    }
    
    override func start() {
        super.start()
        self.beganExecuting()
        
        switch detailType {
        case .Memers:
            showMemers()
        case .Likers:
            showLikers()
        case .Reposters:
            showReposters()
        }
        presentationCompletion?()
        self.finishedExecuting()
    }
    
    private func showLikers() {
        let childDependencyManager = dependencyManager.childDependencyManagerWithAddedConfiguration([:])
        let usersViewController = VUsersViewController(dependencyManager: childDependencyManager)
        
        usersViewController.title = NSLocalizedString("LikersTitle", comment: "")
        usersViewController.usersDataSource = VLikersDataSource(sequence: sequence)
        usersViewController.usersViewContext = VUsersViewContext.Likers
        
        originViewController.navigationController?.pushViewController(usersViewController, animated: true)
    }
    
    private func showReposters() {
        if let vc: VReposterTableViewController = VReposterTableViewController(sequence: sequence, dependencyManager: dependencyManager) {
            originViewController.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func showMemers() {
        if let memeStream = dependencyManager.memeStreamForSequence(sequence) {
            originViewController.navigationController?.pushViewController(memeStream, animated: true)
        }
    }
}