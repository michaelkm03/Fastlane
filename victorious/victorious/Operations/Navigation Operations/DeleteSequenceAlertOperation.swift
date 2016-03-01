//
//  DeleteSequenceAlertOperation.swift
//  victorious
//
//  Created by Vincent Ho on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class DeleteSequenceAlertOperation: NavigationOperation, ActionConfirmationOperation {
    
    private let dependencyManager: VDependencyManager
    private let originViewController: UIViewController
    
    // MARK: - ActionConfirmationOperation
    
    var didConfirmAction: Bool = false
    
    init( originViewController: UIViewController, dependencyManager: VDependencyManager) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
    }
    
    override func start() {
        super.start()
        self.beganExecuting()
        
        let alertController = UIAlertController(title: NSLocalizedString("AreYouSureYouWantToDelete", comment: ""),
            message: nil,
            preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alertController.addAction(
            UIAlertAction(title: NSLocalizedString("CancelButton", comment: ""),
                style: .Cancel,
                handler: { action in
                    self.finishedExecuting()
                }
            )
        )
        alertController.addAction(
            UIAlertAction(title: NSLocalizedString("DeleteButton", comment: ""),
                style: .Destructive,
                handler: { action in
                    self.didConfirmAction = true
                    self.finishedExecuting()
                }
            )
        )
        originViewController.presentViewController(alertController, animated: true, completion: nil)
    }
}
