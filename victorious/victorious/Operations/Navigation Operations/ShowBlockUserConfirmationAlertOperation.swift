//
//  ShowBlockUserConfirmationAlertOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 2/29/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ShowBlockUserConfirmationAlertOperation: NavigationOperation, ActionConfirmationOperation {
    
    private let dependencyManager: VDependencyManager
    private let originViewController: UIViewController
    private let shouldUnblockUser: Bool
    
    // MARK: - ActionConfirmationOperation
    
    var didConfirmAction: Bool = false
    
    init( originViewController: UIViewController, dependencyManager: VDependencyManager, shouldUnblockUser: Bool) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
        self.shouldUnblockUser = shouldUnblockUser
    }
    
    override func start() {
        super.start()
        self.beganExecuting()
        
        let alertController = UIAlertController(title: nil,
            message: nil,
            preferredStyle: .ActionSheet)
        
        alertController.addAction(
            UIAlertAction(
                title: NSLocalizedString("Cancel", comment: "Cancel Button"),
                style: .Cancel,
                handler: { action in
                    self.finishedExecuting()
                }
            )
        )
        
        let title = shouldUnblockUser ? NSLocalizedString("UnblockUser", comment: "") : NSLocalizedString("BlockUser", comment: "")
        alertController.addAction(
            UIAlertAction(
                title: title,
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
