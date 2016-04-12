//
//  LocalNotificationScheduler.swift
//  victorious
//
//  Created by Patrick Lynch on 8/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// A helper for schelduling local notifications that adds the ability to easily cancel
/// notifications and provide deeplink URLs to be executed when notifications are viewed by the user.
class LocalNotificationScheduler: NSObject {
    
    let dependencyManager: VDependencyManager
    
    required init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
    }
    
    /// Key used to store a deeplink URL of the local notification on its `userInfo` dictionary
    class var deplinkURLKey: String { return "com.getvictorious.localNotificationDeeplinkURLKey" }
    
    /// Key used to store an identifier of the local notification on its `userInfo` dictionary
    class var identifierKey: String { return "com.getvictorious.localNotificationDeeplinkIdentifierKey" }
    
    /// Registers settings for local notifications with system.  A permissions dialog will be
    /// presented to the user the first time this is called if permissions has been granted or denied once before.
    func register() {
        let settings = UIUserNotificationSettings(forTypes: [.Badge, .Alert, .Sound], categories: nil )
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
    /// Unschedules notifications that were scheduled using this class's `scheduleNotification(_:identifier:deeplinkUrl:)` method.
    ///
    /// - parameter identifier: The identifier used to schedule the notification.
    func unscheduleNotification( identifier identifier: String ) {
        guard let scheduledLocalNotifications = UIApplication.sharedApplication().scheduledLocalNotifications else {
            return
        }
        for notification in scheduledLocalNotifications {
            if notification.userInfo?[ LocalNotificationScheduler.identifierKey ] != nil {
                    UIApplication.sharedApplication().cancelLocalNotification( notification )
            }
        }
    }
    
    /// Creates, configires and schedules a UILocalNotification.  If a template notification cannot be found
    /// for the identifier provided, nothing is executed.
    ///
    /// - parameter identifier: The identifier of a notification from the template.
    /// - parameter fireDate: The date at which the notification will be presented to the user
    func scheduleNotification( identifier identifier: String, fireDate: NSDate ) {
        if let templateNotification = self.dependencyManager.getNotification( identifier: identifier ) {
            
            self.register() //< Configures settings and prompts for permission if required
            
            var userInfo = [ LocalNotificationScheduler.identifierKey: identifier ]
            if let deeplinkUrl = templateNotification.deeplinkUrl {
                userInfo[ LocalNotificationScheduler.deplinkURLKey ] = deeplinkUrl
            }
            
            let localNotification = UILocalNotification()
            localNotification.fireDate = fireDate
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            localNotification.alertBody = templateNotification.message
            localNotification.alertAction = templateNotification.action
            localNotification.soundName = UILocalNotificationDefaultSoundName
            if let badgeNumber = templateNotification.badgeNumber {
                localNotification.applicationIconBadgeNumber = badgeNumber
            }
            localNotification.userInfo = userInfo
            
            UIApplication.sharedApplication().scheduleLocalNotification( localNotification )
        }
        
    }
}
