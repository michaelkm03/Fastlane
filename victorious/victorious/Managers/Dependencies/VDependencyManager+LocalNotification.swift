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
        static let Notifications    = "localNotifications"
        static let Identifier       = "identifier"
        static let Message          = "message"
        static let Action           = "action"
        static let DeeplinkUrl      = "deeplinkUrl"
        static let BadgeNumber      = "badgeNumber"
    }
    
    /// Parses a `TemplateNotification` object from the template
    ///
    /// :param: identifier The identifier of a notification to find and parse from the template
    func notificationWithIdentifier( identifier: String ) -> TemplateNotification? {
        if let array = self.templateValueOfType( NSArray.self, forKey: Key.Notifications ) as? [AnyObject] {
            for object in array {
                if let dictionary = object as? [ String : AnyObject ],
                    let message = dictionary[ Key.Message ] as? String,
                    let templateIdentifier = dictionary[ Key.Identifier ] as? String where templateIdentifier == identifier {
                        return TemplateNotification(
                            identifier: templateIdentifier,
                            message: message,
                            action: dictionary[ Key.Action ] as? String,
                            deeplinkUrl: dictionary[ Key.DeeplinkUrl ] as? String,
                            badgeNumber: (dictionary[ Key.BadgeNumber ] as? NSNumber)?.integerValue
                        )
                }
            }
        }
        return nil
    }
}