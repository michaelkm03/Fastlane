//
//  VIPSubscribeOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class VIPSubscribeOperation: BackgroundOperation {
    
    let product: VProduct
    
    var purchaseManager: VPurchaseManagerType = VPurchaseManager.sharedInstance()
    
    init(product: VProduct) {
        self.product = product
    }
    
    override func start() {
        
        guard didConfirmActionFromDependencies else {
            cancel()
            finishedExecuting()
            return
        }
        
        beganExecuting()
        
        dispatch_async(dispatch_get_main_queue()) {
            self.purchaseSubscription()
        }
    }
    
    func purchaseSubscription() {
        let success = { (results: Set<NSObject>?) in
            // Force success because we have to deliver the product even if the sever fails for any reason
            VIPValidateSuscriptionOperation(shouldForceSuccess: true).rechainAfter(self).queue()
            self.finishedExecuting()
        }
        let failure = { (error: NSError?) in
            if error == nil {
                self.cancel()
            } else {
                self.error = error
            }
            self.finishedExecuting()
        }
        purchaseManager.purchaseProduct(product, success: success, failure: failure)
    }
}
