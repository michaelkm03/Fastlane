//
//  FlagSequenceAlertOperation.swift
//  victorious
//
//  Created by Vincent Ho on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class FlagSequenceAlertOperation: NavigationOperation {

    private let dependencyManager: VDependencyManager
    private let originViewController: UIViewController
    private let sequence: VSequence
    var didFlagSequence: Bool
    var errorCode: Int
    
    init( originViewController: UIViewController, dependencyManager: VDependencyManager, sequence: VSequence) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.sequence = sequence
        self.didFlagSequence = false
        self.errorCode = 0
        super.init()
    }
    
    override func start() {
        super.start()
        self.beganExecuting()
        
        let alertController = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Button"),
            style: UIAlertActionStyle.Cancel,
            handler: { action in
                self.finishedExecuting()
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Report/Flag", comment: ""),
        style: UIAlertActionStyle.Destructive) { action in
            
            FlagSequenceOperation(sequenceID: self.sequence.remoteId ).queue() { results, error in
                self.didFlagSequence = error == nil
                
                if let error = error {
                    let params = [ VTrackingKeyErrorMessage : error.localizedDescription ?? "" ]
                    VTrackingManager.sharedInstance().trackEvent( VTrackingEventFlagPostDidFail, parameters: params )
                    self.errorCode == error.code
                }
                else {
                    VTrackingManager.sharedInstance().trackEvent( VTrackingEventUserDidFlagPost )
                }
                self.finishedExecuting()
            }
            
        })
        
        originViewController.presentViewController(alertController, animated: true, completion: nil)
    }
}
