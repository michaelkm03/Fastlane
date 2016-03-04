//
//  ShowRepostersOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

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
