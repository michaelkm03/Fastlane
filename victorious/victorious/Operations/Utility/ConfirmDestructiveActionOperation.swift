//
//  ConfirmDestructiveActionOperation.swift
//  victorious
//
//  Created by Vincent Ho on 2/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

final class ConfirmDestructiveActionOperation: AsyncOperation<Void> {
    
    fileprivate let actionTitle: String
    fileprivate let dependencyManager: VDependencyManager
    fileprivate let originViewController: UIViewController
    
    fileprivate let cancelTitle = NSLocalizedString("Cancel", comment: "Cancel Button")
    
    // MARK: - ActionConfirmationOperation
    
    init(actionTitle: String, originViewController: UIViewController, dependencyManager: VDependencyManager) {
        self.actionTitle = actionTitle
        self.originViewController = originViewController
        self.dependencyManager = dependencyManager
    }
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(_ finish: @escaping (_ output: OperationResult<Void>) -> Void) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(
            UIAlertAction(title: self.cancelTitle,
                style: .cancel,
                handler: { action in
                    finish(.cancelled)
                }
            )
        )
        
        alertController.addAction(
            UIAlertAction(title: self.actionTitle,
                style: .destructive,
                handler: { action in
                    finish(.success())
                }
            )
        )
        
        originViewController.present(alertController, animated: true, completion: nil)
    }
}
