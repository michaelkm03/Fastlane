//
//  VIPSubscribeOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

final class VIPSubscribeOperation: AsyncOperation<Void> {
    let product: VProduct
    let validationURL: NSURL?
    
    var purchaseManager: VPurchaseManagerType = VPurchaseManager.sharedInstance()
    
    init(product: VProduct, validationURL: NSURL?) {
        self.product = product
        self.validationURL = validationURL
    }
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(finish: (result: OperationResult<Void>) -> Void) {
        let success = { (results: Set<NSObject>?) in
            // Force success because we have to deliver the product even if the sever fails for any reason
            let validationOperation = VIPValidateSubscriptionOperation(url: self.validationURL, shouldForceSuccess: true)
            validationOperation?.rechainAfter(self).queue() { _ in
                // We optimistically finish with success if purchase has finished, no matter what the validation result it.
                // But we only send the tracking call if validation succeeded
                if validationOperation?.validationSucceeded == true {
                    VTrackingManager.sharedInstance().trackEvent(VTrackingEventRecievedProductReceiptFromBackend)
                }
            }
            finish(result: .success())
        }
        
        let failure = { (error: NSError?) in
            if let error = error {
                finish(result: .failure(error))
            }
            else {
                finish(result: .cancelled)
            }
        }
        
        purchaseManager.purchaseProduct(product, success: success, failure: failure)
    }
}
