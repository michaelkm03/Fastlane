//
//  DeleteSequenceAlertOperation.swift
//  victorious
//
//  Created by Vincent Ho on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class DeleteSequenceAlertOperation: NavigationOperation {
    
    private let dependencyManager: VDependencyManager
    private let originViewController: UIViewController
    private let sequence: VSequence
    private let presentationCompletion: (()->())?
    var didDeleteSequence: Bool
    
    init( originViewController: UIViewController, dependencyManager: VDependencyManager, sequence: VSequence, presentationCompletion: (()->())? ) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.sequence = sequence
        self.presentationCompletion = presentationCompletion
        self.didDeleteSequence = false
        super.init()
    }
    
    override func start() {
        super.start()
        self.beganExecuting()
        
        
        let alertController = UIAlertController(title: NSLocalizedString("AreYouSureYouWantToDelete", comment: ""),
                                                message: nil,
                                                preferredStyle: UIAlertControllerStyle.ActionSheet)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("CancelButton", comment: ""),
            style: UIAlertActionStyle.Cancel,
            handler:nil))

        alertController.addAction(UIAlertAction(title: NSLocalizedString("CancelButton", comment: ""),
            style: UIAlertActionStyle.Cancel,
            handler: { action in
                self.finishedExecuting()
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("DeleteButton", comment: ""),
        style: UIAlertActionStyle.Destructive) { action in
            
            DeleteSequenceOperation(sequenceID: self.sequence.remoteId).queue() { results, error in
                VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidDeletePost)
                self.didDeleteSequence = error == nil
                self.finishedExecuting()
            }
            
        })
        
        originViewController.presentViewController(alertController, animated: true, completion: nil)
    }
}