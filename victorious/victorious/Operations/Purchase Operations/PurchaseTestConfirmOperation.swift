//
//  PurchaseTestConfirmOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class PurchaseTestConfirmOperation: MainQueueOperation, ActionConfirmationOperation {
    
    private let dependencyManager: VDependencyManager
    
    // MARK: - ActionConfirmationOperation
    
    var didConfirmAction: Bool = false
    
    init( dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
    }
    
    override func start() {
        super.start()
        dispatch_after(1.0, showAlert)
    }
    
    func showAlert() {
        beganExecuting()
        
        let title = "Confirm Your Subscription"
        let message = "Do you want to subscribe to VIP Membership for 1 month for $2.99?  This subscription will automatically renew until canceled.\n\n[Simulated for testing]"
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(
            UIAlertAction(title: "Cancel",
                style: .Cancel,
                handler: { action in
                    self.finishedExecuting()
                }
            )
        )
        alertController.addAction(
            UIAlertAction(title: "Confirm",
                style: .Default,
                handler: { action in
                    self.didConfirmAction = true
                    self.finishedExecuting()
                }
            )
        )
        dependencyManager.scaffoldViewController().presentViewController(alertController, animated: true, completion: nil)
    }
}
