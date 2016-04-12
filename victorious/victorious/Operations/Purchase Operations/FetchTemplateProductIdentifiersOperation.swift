//
//  FetchTemplateProductIdentifiersOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class FetchTemplateProductIdentifiersOperation: BackgroundOperation {
    
    var purchaseManager: VPurchaseManagerType = VPurchaseManager.sharedInstance()
    var productsDataSource: TemplateProductsDataSource
    
    init(productsDataSource: TemplateProductsDataSource) {
        self.productsDataSource = productsDataSource
    }
    
    override func start() {
        super.start()
        beganExecuting()
        
        let voteTypeProductIdentifiers = productsDataSource.productIdentifiersForVoteTypes.filter { !$0.characters.isEmpty }
        
        let subscriptionProductIdentiers: [String]
        if let vipSubscriptionProductIdentifier = productsDataSource.vipSubscriptionProductIdentifier {
            subscriptionProductIdentiers = [vipSubscriptionProductIdentifier]
        } else {
            subscriptionProductIdentiers = []
        }
        
        let allProductIdentifiers = voteTypeProductIdentifiers + subscriptionProductIdentiers
        guard allProductIdentifiers.count > 0 else {
            return
        }
        purchaseManager.fetchProductsWithIdentifiers(Set<NSObject>(arrayLiteral: allProductIdentifiers),
            success: { results in
                self.finishedExecuting()
            },
            failure: { error in
                v_log("\(self.dynamicType) FAILURE: Could not fetch products with identifiers \(allProductIdentifiers)")
                self.error = error
                self.finishedExecuting()
            }
        )
    }
}
