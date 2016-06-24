//
//  VNotificationSettingsViewController.swift
//  victorious
//
//  Created by Michael Sena on 12/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VNotificationSettingsViewController: VSettingsSwitchCellDelegate {
    
    func loadSettings() {
        self.setSettings(nil)
        self.settingsError = nil
        
        let notificationPreferencesOperation = DevicePreferencesOperation()
        notificationPreferencesOperation.queue() { results, error, cancelled in
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
        
        notificationUpdateOperation.queue() { [weak navigationController] results, error, cancelled in
            if let _ = error where navigationController != nil {
                let title = NSLocalizedString("ErrorPushNotificationsNotSaved", comment: "" )
                let message = NSLocalizedString("ErrorPushNotificationsNotSavedMessage", comment: "" )

                let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Cancel, handler: nil))
                navigationController?.presentViewController(alertController, animated: true, completion: nil)
            }
        }

        
        
    }
    
    func initializeSettings() {
        self.sections = self.sectionsForTableView()
    }
    
    func configureErrorMessageCell (cell: VNoContentTableViewCell){
        //        cell.setMessage(dependencyManager.errorString)
        //        cell.centered = true;
        //
        //        if ( self.settingsError.code == kErrorCodeUserNotRegistered )
        //        {
        //            [cell showActionButtonWithLabel:NSLocalizedString( @"Open Settings", nil) callback:^void
        //                {
        //                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        //                [[UIApplication sharedApplication] openURL:url];
        //                }];
        //        }
    }
    
    public func settingsDidUpdateFromCell(cell: VSettingsSwitchCell, newValue: Bool, key: String) {
        self.getSettings().updateValue(forKey: key, newValue: newValue)
    }
    
    public func backgroundContainerView() -> UIView {
        return tableView.backgroundView ?? self.view
    }
    
    
    private func sectionsForTableView() -> NSOrderedSet {
        let result = NSMutableOrderedSet()
        let items = dependencyManager.arrayForKey("items")
        
        for item in items {
            if let itemDictionary = item as? NSDictionary,
                let sectionTitle = itemDictionary["section.title"] as? String,
                let sectionArray = itemDictionary["section.items"] as? NSArray
            {
                var sectionRows: [VNotificationSettingsTableRow] = []
                sectionArray.enumerateObjectsUsingBlock(){ (object, _, _) in
                    if let rowDictionary = object as? NSDictionary,
                        let rowTitle = rowDictionary["title"] as? String,
                        let rowKey = rowDictionary["key"] as? String
                    {
                        let row = VNotificationSettingsTableRow(title: rowTitle, enabled: self.getSettings().isKeyEnabled(rowKey), key: rowKey)
                        sectionRows.append(row)
                    }
                }
                let tableViewSection = VNotificationSettingsTableSection(title: sectionTitle, rows: sectionRows)
                result.addObject(tableViewSection)
            }
        }
        
        return result
    }
    
}

