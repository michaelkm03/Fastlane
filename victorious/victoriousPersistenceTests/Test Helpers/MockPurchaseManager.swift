//
//  MockPurchaseManager.swift
//  victorious
//
//  Created by Patrick Lynch on 3/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import victorious

class MockPurchaseManager: NSObject, VPurchaseManagerType {
    
    let error: NSError?
    
    init(error: NSError? = nil) {
        self.error = error
    }
    
    // MARK: - VPurchaseManagerType
    
    var isPurchasingEnabled = true
    
    var isPurchaseRequestActive = false
    
    var purchasedProductIdentifiers = Set<NSObject>()
    
    func isProductIdentifierPurchased(productIdentifier: String) -> Bool {
        return true
    }
    
    func purchaseProduct(product: VProduct, success successCallback: VPurchaseSuccessBlock, failure failureCallback: VPurchaseFailBlock) {
        if let error = self.error {
            failureCallback( error )
        } else {
            successCallback( Set<NSObject>() )
        }
    }
    
    func purchaseProductWithIdentifier(productIdentifier: String, success successCallback: VPurchaseSuccessBlock, failure failureCallback: VPurchaseFailBlock) {
        if let error = self.error {
            failureCallback( error )
        } else {
            successCallback( Set<NSObject>() )
        }
    }
    
    func restorePurchasesSuccess(successCallback: VPurchaseSuccessBlock, failure failureCallback: VPurchaseFailBlock) {
        if let error = self.error {
            failureCallback( error )
        } else {
            successCallback( Set<NSObject>() )
        }
    }
    
    func fetchProductsWithIdentifiers(productIdentifiers: Set<NSObject>, success successCallback: VProductsRequestSuccessBlock, failure failureCallback: VProductsRequestFailureBlock) {
        if let error = self.error {
            failureCallback( error )
        } else {
            successCallback( Set<NSObject>() )
        }
    }
    
    func purchaseableProductForProductIdentifier(productIdentifier: String) -> VProduct {
        abort()
    }
}
