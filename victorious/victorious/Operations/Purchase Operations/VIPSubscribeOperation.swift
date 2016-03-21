//
//  VIPSubscribeOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class VIPSubscribeOperation: MainQueueOperation {
    
    let productIdentifier: String
    
    var purchaseManager: VPurchaseManagerType = VPurchaseManager.sharedInstance()
    
    init(productIdentifier: String) {
        self.productIdentifier = productIdentifier
    }
    
    override func start() {
        super.start()
        
        guard didConfirmActionFromDependencies else {
            cancel()
            finishedExecuting()
            return
        }
        
        beganExecuting()
        
        purchaseManager.purchaseProductWithIdentifier(productIdentifier,
            success: { results in
                // Force success because we have to deliver the product even if the sever fails for any reason
                VIPValidateSuscriptionOperation(shouldForceSuccess: true).rechainAfter(self).queue()
                self.finishedExecuting()
            },
            failure: { error in
                if error == nil {
                    self.cancel()
                } else {
                    self.error = error
                }
                self.finishedExecuting()
            }
        )
    }
}