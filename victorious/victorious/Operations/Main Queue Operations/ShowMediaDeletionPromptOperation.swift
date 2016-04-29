//
//  ShowMediaDeletionPromptOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 4/16/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ShowMediaDeletionPromptOperation: MainQueueOperation {
    
    var confirmedDelete: Bool = false
    private weak var originViewController: UIViewController?
    
    init(originViewController: UIViewController) {
        self.originViewController = originViewController
    }
    
    override func start() {
        super.start()
        self.beganExecuting()
        
        let alertController = VCommentAlertHelper.alertForConfirmDiscardMediaWithDelete(
            {
                self.confirmedDelete = true
                self.finishedExecuting()
            },
            cancel: {
                self.finishedExecuting()
            }
        )
        
        originViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
}
