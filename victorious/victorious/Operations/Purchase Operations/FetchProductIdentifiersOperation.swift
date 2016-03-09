//
//  FetchProductIdentifiersOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class FetchProductIdentifiersOperation: Operation {
    
    var purchaseManager: VPurchaseManager = VPurchaseManager.sharedInstance()
    
    let dependencyManager: VDependencyManager
    
    var error: NSError?
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
    }
    
    override func start() {
        super.start()
        beganExecuting()
        
        let voteTypeProductIdentifiers = (dependencyManager.voteTypes() ?? [])
            .flatMap { $0.productIdentifier }
            .filter { !$0.characters.isEmpty }
        
        let subscriptionProductIdentiers: [String]
        if let vipSubscriptionProductIdentifier = dependencyManager.vipSubscriptionProductIdentifier {
            subscriptionProductIdentiers = [vipSubscriptionProductIdentifier]
        } else {
            subscriptionProductIdentiers = []
        }
        
        let allProductIdentifiers = voteTypeProductIdentifiers + subscriptionProductIdentiers
        
        purchaseManager.fetchProductsWithIdentifiers(Set<NSObject>(arrayLiteral: allProductIdentifiers),
            success: { results in
                self.finishedExecuting()
            },
            failure: { error in
                VLog("\(self.dynamicType) FAILURE: Could not fetch products with identifiers \(allProductIdentifiers)")
                self.error = error
                self.finishedExecuting()
            }
        )
    }
}
