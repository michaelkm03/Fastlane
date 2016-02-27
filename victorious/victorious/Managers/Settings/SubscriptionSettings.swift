//
//  SubscriptionSettings.swift
//  victorious
//
//  Created by Alex Tamoykin on 2/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

@objc class SubscriptionSettings: NSObject {
    let dependencyManager: VDependencyManager
    func getProductIdentifier() -> String? {
        guard let dictionary = self.dependencyManager.templateValueOfType(NSDictionary.self, forKey: kSubscriptionTemplateKey) as? NSDictionary else {
            return nil
        }
        return dictionary[kProductIdentifierTemplateKey] as? String
    }

    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
    }
}
