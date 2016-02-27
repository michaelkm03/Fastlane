//
//  SubscriptionSettings.swift
//  victorious
//
//  Created by Alex Tamoykin on 2/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

@objc class SubscriptionSettings: NSObject {
    let dependencyManager: VDependencyManager
    let purchaseManager: VPurchaseManager
    var productIdentifier: String? {
        guard let dictionary = self.dependencyManager.templateValueOfType(NSDictionary.self, forKey: kSubscriptionTemplateKey) as? NSDictionary else {
            return nil
        }
        return dictionary[kProductIdentifierTemplateKey] as? String
    }

    init(dependencyManager: VDependencyManager, purchaseManager: VPurchaseManager) {
        self.dependencyManager = dependencyManager
        self.purchaseManager = purchaseManager
    }

    func fetchProducts(success: VProductsRequestSuccessBlock?, failure: VProductsRequestFailureBlock?) {
        guard let productIdentifier = productIdentifier else {
            success?(Set<NSObject>())
            return
        }
        let productIdentifiers = Set([productIdentifier])
        purchaseManager.fetchProductsWithIdentifiers(productIdentifiers, success: success) { error in
            VLog("Failed to fetch product with identifier: \(self.productIdentifier). Error: \(error.localizedDescription)")
            failure?(error)
        }
    }
}
