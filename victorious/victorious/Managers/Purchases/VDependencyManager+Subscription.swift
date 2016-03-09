//
//  VDependencyManager+Subscription.swift
//  victorious
//
//  Created by Alex Tamoykin on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

extension VDependencyManager {
    
    var vipSubscriptionProductIdentifier: String? {
        guard let dictionary = templateValueOfType(NSDictionary.self, forKey: "subscription") as? NSDictionary else {
            return nil
        }
        return dictionary["appleProductId"] as? String
    }
}
