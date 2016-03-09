//
//  RestorePurchaseOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class RestorePurchasesOperation: Operation {
    
    var purchaseManager: VPurchaseManagerType = VPurchaseManager.sharedInstance()
    
    var error: NSError?
    
    override func start() {
        super.start()
        beganExecuting()
        
        purchaseManager.restorePurchasesSuccess(
            { results in
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
