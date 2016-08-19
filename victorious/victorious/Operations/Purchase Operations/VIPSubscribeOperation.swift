//
//  VIPSubscribeOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class VIPSubscribeOperation: AsyncOperation<Void> {
    let product: VProduct
    
    var purchaseManager: VPurchaseManagerType = VPurchaseManager.sharedInstance()
    
    init(product: VProduct) {
        self.product = product
    }
    
    override var executionQueue: Queue {
        return .main
    }
    
    override func execute(finish: (result: OperationResult<Void>) -> Void) {
        let success = { (results: Set<NSObject>?) in
            // Force success because we have to deliver the product even if the sever fails for any reason
            VIPValidateSuscriptionOperation(shouldForceSuccess: true).rechainAfter(self).queue()
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
