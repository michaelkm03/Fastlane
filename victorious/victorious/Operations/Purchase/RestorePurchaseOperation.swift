//
//  RestorePurchaseOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

final class RestorePurchasesOperation: AsyncOperation<Void> {
    let validationAPIPath: APIPath
    fileprivate let purchaseManager: VPurchaseManagerType = VPurchaseManager.sharedInstance()
    
    init(validationAPIPath: APIPath) {
        self.validationAPIPath = validationAPIPath
    }
    
    override var executionQueue: Queue {
        return .background
    }
    
    override func execute(_ finish: @escaping (_ result: OperationResult<Void>) -> Void) {
        purchaseManager.restorePurchasesSuccess(
            { results in
                // Force success because we have to deliver the product even if the sever fails for any reason
                VIPValidateSubscriptionOperation(apiPath: self.validationAPIPath, shouldForceSuccess: true)?.rechainAfter(self).queue()
                finish(.success())
            },
            failure: { error in
                finish(.failure(error))
            }
        )
    }
}
