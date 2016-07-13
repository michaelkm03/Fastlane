//
//  VIPFetchSubscriptionOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class VIPFetchSubscriptionOperation: BackgroundOperation {
    var subscriptionProductIdentifier: String?
    
    override func start() {
        guard didConfirmActionFromDependencies else {
            cancel()
            finishedExecuting()
            return
        }
        
        beganExecuting()
        // FUTURE: Remove this testing value when this operation is fully implemented
        subscriptionProductIdentifier = "testingProductIdentifier"
        finishedExecuting()
    }
}
