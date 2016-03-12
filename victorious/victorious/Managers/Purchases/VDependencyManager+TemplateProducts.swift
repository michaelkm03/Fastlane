//
//  VDependencyManager+TemplateProducts.swift
//  victorious
//
//  Created by Patrick Lynch on 3/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VDependencyManager: TemplateProductsDataSource {
    
    var vipSubscriptionProductIdentifier: String? {
        guard let dictionary = templateValueOfType(NSDictionary.self, forKey: "subscription") as? NSDictionary else {
            return nil
        }
        return dictionary["appleProductId"] as? String
    }
    
    var productIdentifiersForVoteTypes: [String] {
        return voteTypes.flatMap { $0.productIdentifier }
    }
    
    func voteTypeForProductIdentifier(productIdentifier: String) -> VVoteType? {
        return voteTypes.filter { $0.productIdentifier == productIdentifier }.first
    }
    
    var voteTypes: [VVoteType] {
        let templateValues = templateValueOfType(NSArray.self, forKey: "voteTypes") as? [[NSObject : AnyObject]] ?? []
        let childDependencyManagers = templateValues.flatMap {
            return VDependencyManager(parentManager: self, configuration: $0, dictionaryOfClassesByTemplateName: nil)
        }
        return childDependencyManagers.flatMap(VVoteType.init)
    }
}
