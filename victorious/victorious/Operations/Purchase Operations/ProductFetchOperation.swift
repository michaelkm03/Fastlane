//
//  ProductFetchOperation.swift
//  victorious
//
//  Created by Sharif Ahmed on 7/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ProductFetchOperation: BackgroundOperation {
    let productIdentifiers: Set<String>
    
    private(set) var products: [VProduct]?
    
    private var purchaseManager: VPurchaseManagerType = VPurchaseManager.sharedInstance()
    
    init(productIdentifiers: [String]) {
        self.productIdentifiers = Set(productIdentifiers.map { $0 })
    }
    
    override func start() {
        super.start()
        beganExecuting()
        
        guard didConfirmActionFromDependencies else {
            cancel()
            finishedExecuting()
            return
        }
        fetchProducts()
    }
    
    func fetchProducts() {
        let success = { (fetchedProducts: Set<NSObject>?) in
            defer {
                self.finishedExecuting()
            }
            guard let products = fetchedProducts?.flatMap({ $0 as? VProduct }) else {
                return
            }
            self.products = products
        }
        let failure = { (error: NSError?) in
            defer {
                self.finishedExecuting()
            }
            if error == nil {
                self.cancel()
            } else {
                self.error = error
            }
        }
        purchaseManager.fetchProductsWithIdentifiers(productIdentifiers, success: success, failure: failure)
    }
}
