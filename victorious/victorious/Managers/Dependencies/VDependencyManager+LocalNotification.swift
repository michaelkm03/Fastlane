//
//  VDependencyManager+LocalNotification.swift
//  victorious
//
//  Created by Patrick Lynch on 8/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// Simple model that represents a local notificaiton configuration parsed from the template
struct TemplateNotification {
    let identifier: String
    let message: String
    let action: String?
    let deeplinkUrl: String?
    let badgeNumber: Int?
}

/// Extension that parses local notifications from the template
extension VDependencyManager {
    
    /// Objective-C compatible identifier for the emotive ballistics cooldown notification
    class var localNotificationBallisticsCooldownIdentifier: String { return "ballisticsCooldown" }
    
    private struct Key {
        static let notifications    = "localNotifications"
        static let identifier       = "identifier"
        static let message          = "message"
        static let action           = "action"
        static let deeplinkUrl      = "deeplinkUrl"
        static let badgeNumber      = "badgeNumber"
    }
    
    /// Parses a `TemplateNotification` object from the template
    ///
    /// - parameter identifier: The identifier of a notification to find and parse from the template
    func getNotification( identifier identifier: String ) -> TemplateNotification? {
        if let array = self.templateValueOfType( NSArray.self, forKey: Key.notifications ) as? [AnyObject] {
            for object in array {
                if let dictionary = object as? [ String : AnyObject ],
                    let message = dictionary[ Key.message ] as? String,
                    let templateIdentifier = dictionary[ Key.identifier ] as? String where templateIdentifier == identifier {
                        return TemplateNotification(
                            identifier: templateIdentifier,
                            message: message,
                            action: dictionary[ Key.action ] as? String,
                            deeplinkUrl: dictionary[ Key.deeplinkUrl ] as? String,
                            badgeNumber: (dictionary[ Key.badgeNumber ] as? NSNumber)?.integerValue
                        )
                }
            }
        }
        return nil
    }
}
