//
//  RestorePurchaseOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class RestorePurchasesOperation: BackgroundOperation {
    
    var purchaseManager: VPurchaseManagerType = VPurchaseManager.sharedInstance()
    
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
