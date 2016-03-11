//
//  FetchTemplateProductIdentifiersOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 3/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class FetchTemplateProductIdentifiersOperation: Operation {
    
    var purchaseManager: VPurchaseManagerType = VPurchaseManager.sharedInstance()
    var productsDataSource: TemplateProductsDataSource
    
    var error: NSError?
    
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
