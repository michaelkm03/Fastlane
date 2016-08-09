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
            let subscription = childDependencyForKey("subscription"),
            let enabled = subscription.numberForKey("enabled")?.boolValue
        else {
            return nil
        }
        let iconImage = subscription.imageForKey("icon")
        return Subscription(enabled: enabled, iconImage: iconImage)
    }
    
    var isVIPEnabled: Bool? {
        return vipSubscription?.enabled
    }
}
