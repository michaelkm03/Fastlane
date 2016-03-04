//
//  ShowMemersOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

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
