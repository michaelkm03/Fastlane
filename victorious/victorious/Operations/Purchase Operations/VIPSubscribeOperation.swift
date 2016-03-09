//
//  VIPSubscribeOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class VIPSubscribeOperation: Operation {
    
    let productIdentifier: String
    
    var purchaseManager: VPurchaseManager = VPurchaseManager.sharedInstance()
    
    var error: NSError?
    
    init(productIdentifier: String) {
        self.productIdentifier = productIdentifier
    }
    
    override func start() {
        super.start()
        beganExecuting()
        
        purchaseManager.purchaseProductWithIdentifier(productIdentifier,
            success: { results in
                self.finishedExecuting()
                VIPSubscriptionSuccessOperation().rechainAfter(self).queue()
            },
            failure: { error in
                self.error = error
                self.finishedExecuting()
            }
        )
    }
}
