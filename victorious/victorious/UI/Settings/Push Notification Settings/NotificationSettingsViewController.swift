//
//  NotificationSettingsViewController.swift
//  victorious
//
//  Created by Michael Sena on 12/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

private struct Constants {
    static let trackingPermissionAuthorizedString = "Authorized"
    static let trackingPermissionDeniedString = "Denied"
    static let userDeviceNotificationNotEnabledErrorCode = 5080
}

private struct NotificationSettingsTableSection {
    var title: String
    var rows: [NotificationSettingsTableRow]
}

private struct NotificationSettingsTableRow {
    var key: String
    var title: String
}

class NotificationSettingsViewController: UITableViewController, VSettingsSwitchCellDelegate, VNotificiationSettingsStateManagerDelegate {
    
    /// MARK : - Properties 
    
    var dependencyManager: VDependencyManager?
    var settings : VNotificationSettings? {
        didSet {
            self.initializeFromSettings()
        }
    }
    
    private var stateManager: VNotificationSettingsStateManager?
    private var permissionsTrackingHelper: VPermissionsTrackingHelper?
    private var sections:[NotificationSettingsTableSection] = []
    
    /// MARK: - UIViewController methods
    
    override func viewDidLoad() {
        stateManager = VNotificationSettingsStateManager(delegate: self)
        permissionsTrackingHelper = VPermissionsTrackingHelper()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        stateManager?.reset()
    }
    
     override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        saveSettings()
    }
    
    /// MARK: - VNotificationSettingsStageManagerDelegate
    
    func onDeviceDidRegisterWithOS() {
        loadSettings()
    }
    
    func onError(error: NSError!) {
        settings = nil
        if (error.code == Constants.userDeviceNotificationNotEnabledErrorCode) {
            displayPermissionsErrorState()
        }
    }
    
    func onDeviceWillRegisterWithServer() {
        self.settings = nil
    }
    
    /// MARK: - Settings Management
    
    func loadSettings() {
        settings = nil
        
        let notificationPreferencesOperation = DevicePreferencesOperation()
        notificationPreferencesOperation.queue() { results, error, cancelled in
            guard error == nil, let mainQueueSettings = notificationPreferencesOperation.mainQueueSettings else {
                self.settings = nil
                self.stateManager?.errorDidOccur(error)

                return
            }
            self.settings = mainQueueSettings
            self.tableView.reloadData()
        }
    }
    
    func saveSettings() {
        guard let settings = self.settings else {
            return
        }
        
        let notificationUpdateOperation = DevicePreferencesOperation(newPreferences: settings.networkPreferences())
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
    
    func initializeFromSettings() {
        self.sections = sectionsForTableView()
    }
    
    /// MARK: - TableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseId = NSStringFromClass(VSettingsSwitchCell.self)
        
        guard
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseId) as? VSettingsSwitchCell,
            let dependencyManager = self.dependencyManager,
            let settings = self.settings
        where
            indexPath.section < sections.count &&
            indexPath.row < sections[indexPath.section].rows.count
        else {
            fatalError("Cannot load cells for push notification screen")
        }
        
        let row = sections[indexPath.section].rows[indexPath.row]
        cell.setTitle(row.title, value: settings.isKeyEnabled(row.key))
        cell.key = row.key
        cell.delegate = self
        cell.setDependencyManager(dependencyManager)
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    // MARK: - SettingsSwitchCell Delegate
    
    func settingsDidUpdateFromCell(cell: VSettingsSwitchCell, newValue: Bool, key: String) {
        guard let settings = self.settings else {
            return
        }
        settings.updateValue(forKey: key, newValue: newValue)
        
        //Update tracking
        let newStateString = newValue ? Constants.trackingPermissionAuthorizedString : Constants.trackingPermissionDeniedString
        permissionsTrackingHelper?.permissionsDidChange(settings.trackingName(forKey: key), permissionState: newStateString)
    }
    
    func backgroundContainerView() -> UIView {
        return tableView.backgroundView ?? self.view
    }
    
    /// MARK: - Internal functions
    
    private func sectionsForTableView() -> [NotificationSettingsTableSection] {
        
        guard let dependencyManager = self.dependencyManager else {
            return []
        }
        
        return []
        
//        let result = NSMutableOrderedSet()
//        let items = dependencyManager.arrayForKey("items")
//        
//        for item in items {
//            if let itemDictionary = item as? NSDictionary,
//                let sectionTitle = itemDictionary["section.title"] as? String,
//                let sectionArray = itemDictionary["section.items"] as? NSArray
//            {
//                var sectionRows: [VNotificationSettingsTableRow] = []
//                sectionArray.enumerateObjectsUsingBlock(){ (object, _, _) in
//                    if let rowDictionary = object as? NSDictionary,
//                        let rowTitle = rowDictionary["title"] as? String,
//                        let rowKey = rowDictionary["key"] as? String
//                    {
//                        let row = VNotificationSettingsTableRow(title: rowTitle, enabled: self.getSettings().isKeyEnabled(rowKey), key: rowKey)
//                        sectionRows.append(row)
//                    }
//                }
//                let tableViewSection = VNotificationSettingsTableSection(title: sectionTitle, rows: sectionRows)
//                result.addObject(tableViewSection)
//            }
//        }
//        
//        return result
    }
    
    private func displayPermissionsErrorState() {
        
    }
    
}

