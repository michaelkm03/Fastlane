//
//  FlagSequenceAlertOperation.swift
//  victorious
//
//  Created by Vincent Ho on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class FlagSequenceAlertOperation: NavigationOperation, UserConfirmationOperation {

    private let dependencyManager: VDependencyManager
    private let originViewController: UIViewController
    
    // MARK: - UserConfirmationOperation
    
    var didConfirmAction: Bool = false
    
    init( originViewController: UIViewController, dependencyManager: VDependencyManager) {
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
    }
    
    override func start() {
        super.start()
        self.beganExecuting()
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(
            UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Button"),
                style: .Cancel,
                handler: { action in
                    self.finishedExecuting()
                }
            )
        )
        alertController.addAction(
            UIAlertAction(title: NSLocalizedString("Report/Flag", comment: ""),
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
