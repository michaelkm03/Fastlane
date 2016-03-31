//
//  TemplateProductsDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 3/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

@objc protocol TemplateProductsDataSource: NSObjectProtocol {
    
    /// The product identifier configured in iTunesConnect that represents
    /// this app's VIP subscription IAP.
    var vipSubscriptionProductIdentifier: String? { get }
    
    /// The product identifiers configured in iTunesConnect that represent
    /// this app's emotive ballistic/experience enhancer IAPs.
    var productIdentifiersForVoteTypes: [String] { get }
    
    var voteTypes: [VVoteType] { get }
    
    func voteTypeForProductIdentifier(productIdentifier: String) -> VVoteType?
}
