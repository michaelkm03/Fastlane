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
    
    fileprivate var simulatedProductIdentifiers = Set<NSObject>()
    
    override var purchasedProductIdentifiers: Set<NSObject> {
        return simulatedProductIdentifiers
    }
    
    override var isPurchaseRequestActive: Bool {
        return false
    }
    
    override func purchaseableProductForProductIdentifier(_ productIdentifier: String) -> VProduct {
        return VPseudoProduct(
            productIdentifier: productIdentifier,
            price: PlaceholderStrings.price,
            localizedDescription: PlaceholderStrings.description,
            localizedTitle: productIdentifier.componentsSeparatedByString(".").last ?? PlaceholderStrings.title
        )
    }
    
    fileprivate var products = Set<VProduct>()
    
    override func fetchProductsWithIdentifiers(_ productIdentifiers: Set<NSObject>, success successCallback: VProductsRequestSuccessBlock, failure failureCallback: VProductsRequestFailureBlock) {
        guard products.isEmpty else {
            successCallback(products)
            return
        }
        
        let productIdentifiers = productIdentifiers.flatMap({ $0 as? String })
        for productIdentifier in productIdentifiers {
            products.insert(purchaseableProductForProductIdentifier(productIdentifier))
        }
        
        // Pretend that we are fetching from the store
        sleep(3)
        
        successCallback( products )
    }
    
    override func purchaseProduct(_ product: VProduct, success successCallback: VPurchaseSuccessBlock, failure failureCallback: VPurchaseFailBlock) {
        
        dispatch_after(1.0) { [weak self] in
            let operation = ShowTestPurchaseConfirmationOperation(
                type: self?.purchaseTypeForProductIdentifier(product.productIdentifier) ?? .Product,
                title: product.localizedTitle,
                duration: product.localizedDescription,
                price: product.price
            )
            operation.queue() { result in
                switch result {
                    case .success:
                        self?.setProductPurchased(product)
                        successCallback(Set<NSObject>([product]))
                    case .failure(let error):
                        failureCallback(error as NSError)
                    case .cancelled:
                        failureCallback(nil)
                }
            }
        }
    }
    
    override func restorePurchasesSuccess(_ successCallback: VPurchaseSuccessBlock, failure failureCallback: VPurchaseFailBlock) {
        dispatch_after( TimeInterval(arc4random_uniform(2) + 1) ) {
            successCallback( Set<NSObject>() )
        }
    }
    
    override func resetPurchases() {
        self.simulatedProductIdentifiers = Set<NSObject>()
        self.purchaseRecord.clear()
    }
    
    // MARK: - Private
    
    func setProductPurchased(_ product: VProduct) {
        self.purchaseRecord.addProductIdentifier(product.productIdentifier)
        self.simulatedProductIdentifiers.insert(product.productIdentifier)
    }
}
