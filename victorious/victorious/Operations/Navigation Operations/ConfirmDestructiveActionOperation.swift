//
//  ConfirmDestructiveActionOperation.swift
//  victorious
//
//  Created by Vincent Ho on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ConfirmDestructiveActionOperation: NavigationOperation, ActionConfirmationOperation {
    
    private let actionTitle: String
    private let dependencyManager: VDependencyManager
    private let originViewController: UIViewController
    
    private let cancelTitle = NSLocalizedString("Cancel", comment: "Cancel Button")
    
    // MARK: - ActionConfirmationOperation
    
    var didConfirmAction: Bool = false
    
    init( actionTitle: String, originViewController: UIViewController, dependencyManager: VDependencyManager) {
        self.actionTitle = actionTitle
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
    }
    
    override func start() {
        super.start()
        self.beganExecuting()
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(
            UIAlertAction(title: self.cancelTitle,
                style: .Cancel,
                handler: { action in
                    self.finishedExecuting()
                }
            )
        )
        alertController.addAction(
            UIAlertAction(title: self.actionTitle,
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
