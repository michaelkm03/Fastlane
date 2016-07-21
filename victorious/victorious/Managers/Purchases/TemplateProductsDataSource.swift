//
//  TemplateProductsDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 3/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

@objc class Subscription: NSObject {
    let productIdentifier: String
    let enabled: Bool
    let iconImage: UIImage?
    
    init(enabled: Bool, iconImage: UIImage? = nil) {
        self.iconImage = iconImage
        self.enabled = enabled
        self.productIdentifier = "placeholder"
    }
}

@objc protocol TemplateProductsDataSource: NSObjectProtocol {
    
    /// An object containing data for the VIP subscription.
    /// Includes product identifier configured in iTunesConnect that represents
    /// this app's VIP subscription IAP.
    var vipSubscription: Subscription? { get }
    
    /// The product identifiers configured in iTunesConnect that represent
    /// this app's emotive ballistic/experience enhancer IAPs.
    var productIdentifiersForVoteTypes: [String] { get }
    
    var voteTypes: [VVoteType] { get }
    
    func voteTypeForProductIdentifier(productIdentifier: String) -> VVoteType?
}
