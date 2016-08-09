//
//  Subscription.swift
//  victorious
//
//  Created by Jarod Long on 8/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

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
