//
//  VDependencyManager+TemplateProducts.swift
//  victorious
//
//  Created by Patrick Lynch on 3/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

extension VDependencyManager {
    var vipSubscription: Subscription? {
        guard
            let subscription = childDependency(forKey: "subscription"),
            let enabled = subscription.number(forKey: "enabled")?.boolValue
        else {
            return nil
        }
        let iconImage = subscription.image(forKey: "icon")
        return Subscription(enabled: enabled, iconImage: iconImage)
    }
    
    var isVIPEnabled: Bool? {
        return vipSubscription?.enabled
    }
}
