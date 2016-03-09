//
//  RestorePurchaseOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class RestorePurchasesOperation: Operation {
    
    var error: NSError?
    
    override func start() {
        super.start()
        beganExecuting()
        
        VPurchaseManager.sharedInstance().restorePurchasesSuccess(
            { results in
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
