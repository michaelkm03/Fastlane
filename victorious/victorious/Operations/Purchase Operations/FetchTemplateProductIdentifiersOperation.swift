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
        
        var productIdentifiersSet = Set<String>()
        let voteTypeProductIdentifiers = productsDataSource.productIdentifiersForVoteTypes.filter { !$0.characters.isEmpty }
        for productIdentifier in voteTypeProductIdentifiers {
            productIdentifiersSet.insert(productIdentifier)
        }
        if let vipSubscriptionProductIdentifier = productsDataSource.vipSubscription?.productIdentifier {
            productIdentifiersSet.insert(vipSubscriptionProductIdentifier)
        }
        guard !productIdentifiersSet.isEmpty else {
            return
        }
        
        purchaseManager.fetchProductsWithIdentifiers(productIdentifiersSet,
            success: { results in
                self.finishedExecuting()
            },
            failure: { error in
                self.error = error
                self.finishedExecuting()
            }
        )
    }
}
