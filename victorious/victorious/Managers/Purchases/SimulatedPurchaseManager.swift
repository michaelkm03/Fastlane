//
//  SimulatedPurchaseManager.swift
//  victorious
//
//  Created by Patrick Lynch on 4/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class SimulatedPurchaseManager: VPurchaseManager {
    
    struct PlaceholderStrings {
        static let price            = "[PRICE]"
        static let description      = "[DESCRIPTION]"
        static let title            = "[TITLE]"
    }
    
    private var simulatedProductIdentifiers = Set<NSObject>()
    
    override var purchasedProductIdentifiers: Set<NSObject> {
        return simulatedProductIdentifiers
    }
    
    override var isPurchaseRequestActive: Bool {
        return false
    }
    
    override func purchaseableProductForProductIdentifier(productIdentifier: String) -> VProduct {
        return VPseudoProduct(
            productIdentifier: productIdentifier,
            price: PlaceholderStrings.price,
            localizedDescription: PlaceholderStrings.description,
            localizedTitle: productIdentifier.componentsSeparatedByString(".").last ?? PlaceholderStrings.title
        )
    }
    
    override func fetchProductsWithIdentifiers(productIdentifiers: Set<NSObject>, success successCallback: VProductsRequestSuccessBlock, failure failureCallback: VProductsRequestFailureBlock) {
        let productIdentifiers = productIdentifiers.flatMap({ $0 as? String })
        var products = Set<VProduct>()
        for productIdentifier in productIdentifiers {
            products.insert(purchaseableProductForProductIdentifier(productIdentifier))
        }
        successCallback( products )
    }
    
    override func purchaseProduct(product: VProduct, success successCallback: VPurchaseSuccessBlock, failure failureCallback: VPurchaseFailBlock) {
        
        dispatch_after(1.0) { [weak self] in
            let operation = ShowTestPurchaseConfirmationOperation(
                type: self?.purchaseTypeForProductIdentifier(product.productIdentifier) ?? .Product,
                title: product.localizedTitle,
                duration: product.localizedDescription,
                price: product.price
            )
            operation.queue() { error, canceled in
                if !canceled {
                    self?.setProductPurchased(product)
                    successCallback( Set<NSObject>([product]) )
                } else {
                    failureCallback(nil)
                }
            }
        }
    }
    
    override func restorePurchasesSuccess(successCallback: VPurchaseSuccessBlock, failure failureCallback: VPurchaseFailBlock) {
        dispatch_after( NSTimeInterval(arc4random_uniform(2) + 1) ) {
            successCallback( Set<NSObject>() )
        }
    }
    
    override func resetPurchases() {
        self.simulatedProductIdentifiers = Set<NSObject>()
        self.purchaseRecord.clear()
    }
    
    // MARK: - Private
    
    func setProductPurchased(product: VProduct) {
        
        // In the case of subscriptions, set the current user as subscriped and provide expiration date
        let type = self.purchaseTypeForProductIdentifier(product.productIdentifier)
        if type == .Subscription, let currentUser =  VCurrentUser.user() {
            let dateComponents = NSDateComponents()
            dateComponents.month = 1
            let now = NSDate()
            let calendar = NSCalendar.currentCalendar()
            let expirationDate = calendar.dateByAddingComponents(dateComponents, toDate: now, options: [])
            currentUser.vipEndDate = expirationDate
        }
        
        self.purchaseRecord.addProductIdentifier(product.productIdentifier)
        self.simulatedProductIdentifiers.insert(product.productIdentifier)
    }
}
