//
//  ConfirmDestructiveActionOperation.swift
//  victorious
//
//  Created by Vincent Ho on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

final class ConfirmDestructiveActionOperation: AsyncOperation<Void>, ActionConfirmationOperation {
    
    private let actionTitle: String
    private let dependencyManager: VDependencyManager
    private let originViewController: UIViewController
    
    private let cancelTitle = NSLocalizedString("Cancel", comment: "Cancel Button")
    
    // MARK: - ActionConfirmationOperation
    
    var didConfirmAction: Bool = false
    
    init(actionTitle: String, originViewController: UIViewController, dependencyManager: VDependencyManager) {
        self.actionTitle = actionTitle
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
    }
    
    override var executionQueue: NSOperationQueue {
        return .mainQueue()
    }
    
    override func execute(finish: (output: OperationResult<Void>) -> Void) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(
            UIAlertAction(title: self.cancelTitle,
                style: .Cancel,
                handler: { action in
                    finish(output: .cancelled)
                }
            )
        )
        alertController.addAction(
            UIAlertAction(title: self.actionTitle,
                style: .Destructive,
                handler: { action in
                    self.didConfirmAction = true
                    finish(output: .success())
                }
            )
        )
        originViewController.presentViewController(alertController, animated: true, completion: nil)
    }
}
