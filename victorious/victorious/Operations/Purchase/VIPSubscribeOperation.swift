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
    let validationAPIPath: APIPath
    
    var purchaseManager: VPurchaseManagerType = VPurchaseManager.sharedInstance()
    
    init(product: VProduct, validationAPIPath: APIPath) {
        self.product = product
        self.validationAPIPath = validationAPIPath
    }
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(_ finish: @escaping (_ result: OperationResult<Void>) -> Void) {
        let success = { (results: Set<NSObject>?) in
            // Force success because we have to deliver the product even if the sever fails for any reason
            guard let validationOperation = VIPValidateSubscriptionOperation(apiPath: self.validationAPIPath, shouldForceSuccess: true) else {
                finish(.success())
                return
            }
            
            validationOperation.queue { [weak validationOperation] _ in
                // We optimistically finish with success if purchase has finished, no matter what the validation result it.
                // But we only send the tracking call if validation succeeded
                if validationOperation?.validationSucceeded == true {
                    VTrackingManager.sharedInstance().trackEvent(VTrackingEventRecievedProductReceiptFromBackend)
                }
                
                finish(.success())
            }
        }
        
        let failure = { (error: NSError?) in
            if let error = error {
                finish(.failure(error))
            }
            else {
                finish(.cancelled)
            }
        }
        
        purchaseManager.purchaseProduct(product, success: success, failure: failure)
    }
}
