//
//  RestorePurchaseOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class RestorePurchasesOperation: AsyncOperation<Void> {
    
    var purchaseManager: VPurchaseManagerType = VPurchaseManager.sharedInstance()
    
    override var executionQueue: NSOperationQueue {
        return .v_globalBackgroundQueue
    }
    
    override func execute(finish: (result: OperationResult<Void>) -> Void) {
        purchaseManager.restorePurchasesSuccess(
            { results in
                // Force success because we have to deliver the product even if the sever fails for any reason
                VIPValidateSuscriptionOperation(shouldForceSuccess: true).rechainAfter(self).queue()
                finish(result: .success())
            },
            failure: { error in
                finish(result: .failure(error))
            }
        )
    }
}
