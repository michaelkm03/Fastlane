//
//  NotificationSettingsViewController.swift
//  victorious
//
//  Created by Darvish Kamalia
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

private struct Constants {
    static let trackingPermissionAuthorizedString = "Authorized"
    static let trackingPermissionDeniedString = "Denied"
    static let userDeviceNotificationNotEnabledErrorCode = 5080
    static let dependencyManagerKey = "push.notifications.screen"
    static let cellIdentifier = "VSettingsSwitchCell"
    static let sectionTitleColorKey = "color.text.section.title"
    static let sectionTitleFontKey = "font.text.section.title"
    static let tableViewSeparatorColorKey = "color.separator.navigation.items"
    static let itemsArrayKey = "items"
    static let sectionItemsKey = "section.items"
    static let sectionTitleKey = "section.title"
    static let creatorNameMacro = "%%CREATOR_NAME%%"
    static let tableViewRowHeight: CGFloat = 44
    static let tableViewHeaderHeight: CGFloat = 35
    static let tableViewHeaderLeftPadding: CGFloat = 10
    static let tableViewSeparatorLeftPadding: CGFloat = 10
    static let errorStateViewHeight: CGFloat = 100
    static let errorStateViewWidthMultiplier: CGFloat = 0.8
    static let activityIndicatorSideLength: CGFloat = 50
}

struct NotificationSettingsTableSection {
    var title: String
    var rows: [NotificationSettingsTableRow]
}

struct NotificationSettingsTableRow {
    var key: String
    var title: String
}

class NotificationSettingsViewController: UITableViewController, VSettingsSwitchCellDelegate, VNotificiationSettingsStateManagerDelegate, VBackgroundContainer {
    
    // MARK : - Properties
    
    private var dependencyManager: VDependencyManager?
    var settings : VNotificationSettings? {
        didSet {
            initializeSections()
            tableView.reloadData()
        }
    }
    
    private var stateManager: VNotificationSettingsStateManager?
    private var permissionsTrackingHelper: VPermissionsTrackingHelper?
    private var sections:[NotificationSettingsTableSection] = []
    private var errorStateView: CtAErrorState?
    private var canLoadSettings = true
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    // MARK: - UIViewController methods
    
    override func viewDidLoad() {
        stateManager = VNotificationSettingsStateManager(delegate: self)
        permissionsTrackingHelper = VPermissionsTrackingHelper()
        let cellNib = UINib(nibName: "VSettingsSwitchCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: Constants.cellIdentifier)
        tableView.separatorColor = UIColor.clearColor()
        tableView.bounces = true
        spinner.frame = CGRect(center: tableView.bounds.center, size: CGSize(width: Constants.activityIndicatorSideLength, height: Constants.activityIndicatorSideLength))
        createErrorStateView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (canLoadSettings) {
            stateManager?.reset()
            styleWithDependencyManager()
            canLoadSettings = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        saveSettings()
    }
    
    override func viewDidDisappear(animated: Bool) {
        canLoadSettings = true //Only reload once the screen disappears completely
    }
    
    // MARK: - VNotificationSettingsStageManagerDelegate
    
    func onDeviceDidRegisterWithOS() {
        loadSettings()
        errorStateView?.removeFromSuperview()
    }
    
    func onError(error: NSError!) {
        settings = nil
        if let errorStateView = self.errorStateView where error.code == Constants.userDeviceNotificationNotEnabledErrorCode {
            view.addSubview(errorStateView)
        }
    }
    
    func onDeviceWillRegisterWithServer() {
        self.settings = nil
    }
    
    // MARK: - Settings Management
    
    func loadSettings() {
        settings = nil
        startSpinner()
        let notificationPreferencesOperation = DevicePreferencesOperation()
        notificationPreferencesOperation.queue() { results, error, cancelled in
            self.stopSpinner()
            guard error == nil, let mainQueueSettings = notificationPreferencesOperation.mainQueueSettings else {
                self.settings = nil
                self.stateManager?.errorDidOccur(error)

                return
            }
            self.settings = mainQueueSettings
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
    
    func initializeSections() {
        self.sections = sectionsForTableView()
    }
    
    // MARK: - TableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.cellIdentifier) as? VSettingsSwitchCell,
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
        cell.selectionStyle = .None
        
        if (indexPath.row == sections[indexPath.section].rows.count - 1) {
            cell.setSeparatorHidden(true)
        }
    
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return settings == nil ? 0 : sections.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Constants.tableViewRowHeight
    }
    
    override  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let dependencyManager = self.dependencyManager where section < sections.count else {
            return nil
        }
        let headerLabel = UILabel()
        headerLabel.text = sections[section].title
        headerLabel.font = dependencyManager.fontForKey(Constants.sectionTitleFontKey)
        headerLabel.textColor = dependencyManager.colorForKey(Constants.sectionTitleColorKey)
        headerLabel.sizeToFit()
        let headerContainer = UIView()
        headerContainer.addSubview(headerLabel)
        headerContainer.v_addFitToParentConstraintsToSubview(headerLabel, leading: Constants.tableViewHeaderLeftPadding, trailing: 0, top: 0, bottom: 0)
        return headerContainer
    }
    
    override  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.tableViewHeaderHeight
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
    
    // MARK: - Internal functions
    
    func sectionsForTableView() -> [NotificationSettingsTableSection] {
        guard let dependencyManager = self.dependencyManager else {
            return []
        }
        
        var result: [NotificationSettingsTableSection] = []
        let items = dependencyManager.arrayForKey(Constants.itemsArrayKey)
        
        for item in items {
            if let itemDictionary = item as? [String : AnyObject],
                let sectionTitle = itemDictionary[Constants.sectionTitleKey] as? String,
                let sectionArray = itemDictionary[Constants.sectionItemsKey] as? [AnyObject]
            {
                let sectionRows: [NotificationSettingsTableRow] = sectionArray.map(){ (object) in
                    if  let rowDictionary = object as? [String : AnyObject],
                        var rowTitle = rowDictionary["title"] as? String,
                        let rowKey = rowDictionary["key"] as? String
                    {
                        if (rowKey == VNotificationSettingType.postFromCreator.rawValue) {
                            let appInfo = VAppInfo(dependencyManager: dependencyManager)
                            rowTitle = rowTitle.stringByReplacingOccurrencesOfString(Constants.creatorNameMacro, withString: appInfo.ownerName ?? "Creator")
                        }
                        return NotificationSettingsTableRow(key: rowKey, title: rowTitle)
                    }
                    return NotificationSettingsTableRow(key: "", title: "")
                }
                
                result.append(NotificationSettingsTableSection(title: sectionTitle, rows: sectionRows))
            }
        }
        
        return result
    }
    
    private func createErrorStateView() {
        if let errorStateView = dependencyManager?.createErrorStateView(actionType: .openSettings) {
            errorStateView.frame = CGRect(center: self.tableView.bounds.center, size: CGSize(width: Constants.errorStateViewWidthMultiplier * tableView.frame.width, height: Constants.errorStateViewHeight))
           self.errorStateView = errorStateView
        }
    }
    
    private func startSpinner() {
        view.addSubview(spinner)
        spinner.startAnimating()
    }
    
    private func stopSpinner() {
        spinner.stopAnimating()
        spinner.removeFromSuperview()
    }
    
    // MARK: - Dependency Manager
    
    func setDependencyManager(dependencyManager: VDependencyManager) {
       self.dependencyManager = dependencyManager
    }
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> NotificationSettingsViewController {
        let viewController = NotificationSettingsViewController(style: .Grouped)
        viewController.setDependencyManager(dependencyManager)
        return viewController
    }
    
    func styleWithDependencyManager() {
        guard let dependencyManager = self.dependencyManager else {
            return
        }
        
        tableView.backgroundView = UIView()
        dependencyManager.addBackgroundToBackgroundHost(self)
    }
}
