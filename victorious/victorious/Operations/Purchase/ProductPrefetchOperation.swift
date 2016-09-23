//
//  ProductPrefetchOperation.swift
//  victorious
//
//  Created by Tian Lan on 9/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// This operation tries to ask purchase manager to pre-fetch products from the store.
/// We do this optimistically (no handling failures), because purchase manager will handle the refetch if this prefetch failed.
final class ProductPrefetchOperation: SyncOperation<Void> {
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
                case .success(let productIdentifiers): ProductFetchOperation(productIdentifiers: productIdentifiers).queue()
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
