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
    
    private var simulatedProductIdentifiers = Set<AnyHashable>()
    
    override var purchasedProductIdentifiers: Set<AnyHashable> {
        return simulatedProductIdentifiers
    }
    
    override var isPurchaseRequestActive: Bool {
        return false
    }
    
    override func purchaseableProduct(forProductIdentifier productIdentifier: String) -> VProduct {
        return VPseudoProduct(
            productIdentifier: productIdentifier,
            price: PlaceholderStrings.price,
            localizedDescription: PlaceholderStrings.description,
            localizedTitle: productIdentifier.components(separatedBy: ".").last ?? PlaceholderStrings.title
        )
    }
    
    private var products = Set<VProduct>()
    
    override func fetchProducts(withIdentifiers productIdentifiers: Set<AnyHashable>, success successCallback: @escaping VProductsRequestSuccessBlock, failure failureCallback: @escaping VProductsRequestFailureBlock) {
        guard products.isEmpty else {
            successCallback(products)
            return
        }
        
        let productIdentifiers = productIdentifiers.flatMap({ $0 as? String })
        for productIdentifier in productIdentifiers {
            products.insert(purchaseableProduct(forProductIdentifier: productIdentifier))
        }
        
        // Pretend that we are fetching from the store
        sleep(3)
        
        successCallback(products)
    }
    
    override func purchaseProduct(_ product: VProduct, success successCallback: @escaping VPurchaseSuccessBlock, failure failureCallback: @escaping VPurchaseFailBlock) {
        dispatch_after(1.0) { [weak self] in
            let operation = ShowTestPurchaseConfirmationOperation(
                type: self?.purchaseType(forProductIdentifier: product.productIdentifier) ?? .product,
                title: product.localizedTitle,
                duration: product.localizedDescription,
                price: product.price
            )
            
            operation.queue { result in
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
    
    override func restorePurchasesSuccess(_ successCallback: @escaping VPurchaseSuccessBlock, failure failureCallback: @escaping VPurchaseFailBlock) {
        dispatch_after(TimeInterval(arc4random_uniform(2) + 1)) {
            successCallback(Set<AnyHashable>())
        }
    }
    
    override func resetPurchases() {
        simulatedProductIdentifiers = Set<AnyHashable>()
        purchaseRecord.clear()
    }
    
    // MARK: - Private
    
    func setProductPurchased(_ product: VProduct) {
        purchaseRecord.addProductIdentifier(product.productIdentifier)
        _ = simulatedProductIdentifiers.insert(product.productIdentifier)
    }
}
