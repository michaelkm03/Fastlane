//
//  VNotificationSettingsViewController.swift
//  victorious
//
//  Created by Michael Sena on 12/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VNotificationSettingsViewController {
    
    func loadSettings() {
        self.setSettings(nil)
        self.settingsError = nil
        
        let notificationPreferencesOperation = DevicePreferencesOperation()
        notificationPreferencesOperation.queue() { error in
            guard error == nil, let mainQueueSettings = notificationPreferencesOperation.mainQueueSettings else {
                self.setSettings(nil)
                self.stateManager.errorDidOccur(error)
                self.settingsError = error
                return
            }
            self.setSettings(mainQueueSettings)
            self.tableView.reloadData()
        }
    }
    
    func saveSettings(notificationSettings: VNotificationSettings) {
        
        let notificationUpdateOperation = DevicePreferencesOperation(newPreferences: notificationSettings.networkPreferences())
        let navigationController = self.navigationController
        
        notificationUpdateOperation.queue() { [weak navigationController] error in
            if let _ = error where navigationController != nil {
                let title = NSLocalizedString("ErrorPushNotificationsNotSaved", comment: "" )
                let message = NSLocalizedString("ErrorPushNotificationsNotSavedMessage", comment: "" )

                let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
                navigationController?.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
}

