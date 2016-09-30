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
    
    fileprivate let purchaseManager: VPurchaseManagerType = VPurchaseManager.sharedInstance()
    
    init(productIdentifiers: [String]) {
        self.productIdentifiers = Set(productIdentifiers.map { $0 })
    }
    
    override var executionQueue: Queue {
        return .background
    }
    
    override func execute(_ finish: (_ result: OperationResult<[VProduct]>) -> Void) {
        let success = { (fetchedProducts: Set<NSObject>?) in
            guard let products = fetchedProducts?.flatMap({ $0 as? VProduct }) else {
                finish(.failure(NSError(domain: "ProductFetchOperation", code: -1, userInfo: nil)))
                return
            }
            finish(.success(products))
        }
        
        let failure = { (error: NSError?) in
            if let error = error {
                finish(.failure(error))
            }
            else {
                finish(.cancelled)
            }
        }
        
        purchaseManager.fetchProductsWithIdentifiers(productIdentifiers, success: success, failure: failure)
    }
}
