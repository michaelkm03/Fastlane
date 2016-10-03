//
//  MockPurchaseManager.swift
//  victorious
//
//  Created by Patrick Lynch on 3/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import victorious
import XCTest

class MockPurchaseManager: NSObject, VPurchaseManagerType {
    
    let error: NSError?
    
    init(error: NSError? = nil) {
        self.error = error
    }
    
    // MARK: - VPurchaseManagerType
    
    var isPurchaseRequestActive = false
    
    var purchasedProductIdentifiers = Set<NSObject>()
    
    func isProductIdentifierPurchased(_ productIdentifier: String) -> Bool {
        return true
    }
    
    func purchaseProduct(_ product: VProduct, success successCallback: VPurchaseSuccessBlock, failure failureCallback: VPurchaseFailBlock) {
        if let error = self.error {
            failureCallback( error )
        } else {
            successCallback( Set<NSObject>() )
        }
    }
    
    func purchaseProductWithIdentifier(_ productIdentifier: String, success successCallback: VPurchaseSuccessBlock, failure failureCallback: VPurchaseFailBlock) {
        if let error = self.error {
            failureCallback( error )
        } else {
            successCallback( Set<NSObject>() )
        }
    }
    
    func restorePurchasesSuccess(_ successCallback: VPurchaseSuccessBlock, failure failureCallback: VPurchaseFailBlock) {
        if let error = self.error {
            failureCallback( error )
        } else {
            successCallback( Set<NSObject>() )
        }
    }
    
    func fetchProductsWithIdentifiers(_ productIdentifiers: Set<NSObject>, success successCallback: VProductsRequestSuccessBlock, failure failureCallback: VProductsRequestFailureBlock) {
        if let error = self.error {
            failureCallback( error )
        } else {
            successCallback( Set<NSObject>() )
        }
    }
    
    func purchaseableProduct(forProductIdentifier productIdentifier: String) -> VProduct {
        XCTFail("MockPurchaseManager :: purchaseableProductForProductIdentifier :: Not yet implemented")
        abort()
    }
    
    func resetPurchases() {
        XCTFail("MockPurchaseManager :: resetPurchases :: Not yet implemented")
        abort()
    }
    
    func purchaseType(forProductIdentifier productIdentifier: String) -> VPurchaseType {
        XCTFail("MockPurchaseManager :: purchaseTypeForProductIdentifier :: Not yet implemented")
        abort()
    }
}
