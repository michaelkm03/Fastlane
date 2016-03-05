//
//  VDependencyManager+Subscription.swift
//  victorious
//
//  Created by Alex Tamoykin on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

extension VDependencyManager {
    
    var greetingText: String {
        return stringForKey("greeting.text")
    }

    var greetingFont: UIFont {
        return fontForKey("greeting.font")
    }

    var greetingColor: UIColor {
        return colorForKey("greeting.color")
    }

    var subscribeColor: UIColor {
        return colorForKey("subscribe.color")
    }

    var subscribeText: String {
        return stringForKey("subscribe.text")
    }

    var subscribeFont: UIFont {
        return fontForKey("subscribe.font")
    }

    var backgroundColor: UIColor? {
        let background = templateValueOfType( VSolidColorBackground.self, forKey: "background") as? VSolidColorBackground
        return background!.backgroundColor
    }
    
    var subscriptionProductIdentifier: String? {
        guard let dictionary = templateValueOfType(NSDictionary.self, forKey: "subscription") as? NSDictionary else {
            return nil
        }
        return dictionary["appleProductId"] as? String
    }
}
