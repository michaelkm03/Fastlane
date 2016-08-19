//
//  RestorePurchaseOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class RestorePurchasesOperation: BackgroundOperation {
    let validationURL:NSURL?
    
    var purchaseManager: VPurchaseManagerType = VPurchaseManager.sharedInstance()
    
    init(validationURL: NSURL?) {
        self.validationURL = validationURL
    }
    
    override func start() {
        super.start()
        beganExecuting()
        
        purchaseManager.restorePurchasesSuccess(
            { results in
                // Force success because we have to deliver the product even if the sever fails for any reason
                VIPValidateSubscriptionOperation(url: self.validationURL, shouldForceSuccess: true)?.rechainAfter(self).queue()
                self.finishedExecuting()
            },
            failure: { error in
                self.error = error
                self.finishedExecuting()
            }
        )
    }
}
