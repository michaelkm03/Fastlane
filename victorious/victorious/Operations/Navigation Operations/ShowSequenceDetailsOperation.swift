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
    
    required init( originViewController: UIViewController, dependencyManager: VDependencyManager, sequence: VSequence) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.sequence = sequence
    }
    
    override func start() {
        super.start()
        self.beganExecuting()
        
        guard let navigationController = originViewController.navigationController else {
            assertionFailure("\(self.dynamicType) requires a navigation controller.")
            return
        }
        
        let childDependencyManager = dependencyManager.childDependencyManagerWithAddedConfiguration([:])
        let usersViewController = VUsersViewController(dependencyManager: childDependencyManager)
        
        usersViewController.title = NSLocalizedString("LikersTitle", comment: "")
        usersViewController.usersDataSource = VLikersDataSource(sequence: sequence)
        usersViewController.usersViewContext = VUsersViewContext.Likers
        
        navigationController.pushViewController(usersViewController, animated: true)
        
        self.finishedExecuting()
    }
}


class ShowMemersOperation: NavigationOperation {
    
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
        
        guard let memeStream = dependencyManager.templateValueOfType(VStreamCollectionViewController.self,
            forKey: "memeStream",
            withAddedDependencies:[ VSequenceIDKey: sequence.remoteId ]) as? VStreamCollectionViewController else  {
                self.finishedExecuting()
                return
        }
        
        let noContentView: VNoContentView = VNoContentView.v_fromNib()
        noContentView.icon = UIImage(named: "noMemeIcon")?.imageWithRenderingMode(.AlwaysTemplate)
        noContentView.title = NSLocalizedString("NoMemersTitle", comment:"")
        noContentView.message = NSLocalizedString("NoMemersMessage", comment:"")
        noContentView.resetInitialAnimationState()
        noContentView.setDependencyManager(self.dependencyManager)
        
        memeStream.navigationItem.title = memeStream.currentStream.name
        memeStream.noContentView = noContentView
        
        originViewController.navigationController?.pushViewController(memeStream, animated: true)
        
        self.finishedExecuting()
    }
}


class ShowRepostersOperation: NavigationOperation {
    
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
        
        if let vc: VReposterTableViewController = VReposterTableViewController(sequence: sequence, dependencyManager: dependencyManager) {
            originViewController.navigationController?.pushViewController(vc, animated: true)
        }
        
        self.finishedExecuting()
    }
}
