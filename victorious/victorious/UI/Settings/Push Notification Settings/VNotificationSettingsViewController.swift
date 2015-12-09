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
        let persistentStore = MainPersistentStore()
        
        let notificationPreferencesOperation = DevicePreferencesOperation()
        notificationPreferencesOperation.queue() { error in
            if let error = error {
                self.stateManager.errorDidOccur(error)
            } else {
                persistentStore.sync{ context in
                    let settings = context.createObjectAndSave({ (notificationSettings: VNotificationSettings) -> () in
                        notificationSettings.populate(fromSourceModel: notificationPreferencesOperation.notificationPreferences!)
                    })
                    self.setSettings(settings)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func saveSettings(notificationSettings: VNotificationSettings) {
        
        let notificationUpdateOperation = DevicePreferencesOperation(newPreferences: notificationSettings.networkPreferences())
        let navigationController = self.navigationController
        
        notificationUpdateOperation.queue() { [weak navigationController] error in
            if let _ = error where navigationController != nil {
                let title = NSLocalizedString("ErrorPushNotificationsNotSaved", comment: "" )
                let message = NSLocalizedString("ErrorPushNotificationsNotSavedMessage", comment: "" )

                let alertController = VAlertController.alertWithTitle(title, message: message)
                alertController.addAction(VAlertAction.cancelButtonWithTitle(NSLocalizedString("OK", comment: ""), handler: nil))
                alertController.presentInViewController(navigationController, animated: true, completion: nil)
            }
        }
    }
    
}

