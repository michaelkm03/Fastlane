//
//  ProductFetchOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

final class ProductFetchOperation: AsyncOperation<[VProduct]> {
    let productIdentifiers: Set<String>
    
    private let purchaseManager: VPurchaseManagerType = VPurchaseManager.sharedInstance()
    
    init(productIdentifiers: [String]) {
        self.productIdentifiers = Set(productIdentifiers.map { $0 })
    }
    
    override var executionQueue: Queue {
        return .background
    }
    
    override func execute(finish: (result: OperationResult<[VProduct]>) -> Void) {
        let success = { (fetchedProducts: Set<NSObject>?) in
            guard let products = fetchedProducts?.flatMap({ $0 as? VProduct }) else {
                finish(result: .failure(NSError(domain: "ProductFetchOperation", code: -1, userInfo: nil)))
                return
            }
            finish(result: .success(products))
        }
        
        let failure = { (error: NSError?) in
            if let error = error {
                finish(result: .failure(error))
            }
            else {
                finish(result: .cancelled)
            }
        }
        
        purchaseManager.fetchProductsWithIdentifiers(productIdentifiers, success: success, failure: failure)
    }
}

final class PreFetchProductOperation: SyncOperation<Void> {
    private let subscriptionFetchAPIPath: APIPath
    
    init?(dependencyManager: VDependencyManager) {
        guard let subscriptionFetchAPIPath = dependencyManager.subscriptionFetchAPIPath else {
            return nil
        }
        self.subscriptionFetchAPIPath = subscriptionFetchAPIPath
    }
    
    override var executionQueue: Queue {
        return .background
    }
    
    override func execute() -> OperationResult<Void> {
        guard let request = VIPFetchSubscriptionRequest(apiPath: subscriptionFetchAPIPath) else {
            return .failure(NSError(domain: "RequestInitializationFailure", code: 1, userInfo: nil))
        }
        
        RequestOperation(request: request).queue { result in
            switch result {
                case .success(let productIdentifiers):
                    ProductFetchOperation(productIdentifiers: productIdentifiers).queue()
                case .failure, .cancelled: break
            }
        }
        
        return .success()
    }
}

private extension VDependencyManager {
    var subscriptionFetchAPIPath: APIPath? {
        return networkResources?.apiPathForKey("inapp.sku.URL")
    }
}
