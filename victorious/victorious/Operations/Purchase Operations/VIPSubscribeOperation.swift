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
                VIPSubscriptionSuccessOperation().rechainAfter(self).queue()
                self.finishedExecuting()
            },
            failure: { error in
                self.error = error
                self.finishedExecuting()
            }
        )
    }
}
