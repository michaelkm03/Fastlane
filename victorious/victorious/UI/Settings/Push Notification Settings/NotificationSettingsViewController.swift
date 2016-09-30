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
    
    fileprivate var dependencyManager: VDependencyManager!
    var settings : NotificationSettings? {
        didSet {
            initializeSections()
            tableView.reloadData()
        }
    }
    
    fileprivate var stateManager: VNotificationSettingsStateManager?
    fileprivate var permissionsTrackingHelper: VPermissionsTrackingHelper?
    fileprivate var sections:[NotificationSettingsTableSection] = []
    fileprivate var errorStateView: CTAErrorState?
    fileprivate var shouldFetchSettings = true
    fileprivate let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    // MARK: - UIViewController methods
    
    override func viewDidLoad() {
        stateManager = VNotificationSettingsStateManager(delegate: self)
        permissionsTrackingHelper = VPermissionsTrackingHelper()
        let cellNib = UINib(nibName: "VSettingsSwitchCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: Constants.cellIdentifier)
        tableView.separatorColor = UIColor.clear
        tableView.bounces = true
        tableView.rowHeight = Constants.tableViewRowHeight
        spinner.frame = CGRect(center: tableView.bounds.center, size: CGSize(width: Constants.activityIndicatorSideLength, height: Constants.activityIndicatorSideLength))
        createErrorStateView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (shouldFetchSettings) {
            stateManager?.reset()
            styleWithDependencyManager()
            shouldFetchSettings = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveSettings()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        shouldFetchSettings = true //Only reload once the screen disappears completely
    }
    
    // MARK: - VNotificationSettingsStageManagerDelegate
    
    func onDeviceDidRegisterWithOS() {
        loadSettings()
        errorStateView?.removeFromSuperview()
    }
    
    func onError(_ error: NSError!) {
        settings = nil
        if let errorStateView = self.errorStateView , error.code == Constants.userDeviceNotificationNotEnabledErrorCode {
            view.addSubview(errorStateView)
        }
    }
    
    func onDeviceWillRegisterWithServer() {
        settings = nil
    }
    
    // MARK: - Settings Management
    
    func loadSettings() {
        settings = nil
        startSpinner()
        
        RequestOperation(request: DevicePreferencesRequest()).queue { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.stopSpinner()
            
            switch result {
                case .success(let preferences):
                    var settings = NotificationSettings()
                    settings.populate(fromSourceModel: preferences)
                    strongSelf.settings = settings
                
                case .failure(_), .cancelled:
                    strongSelf.settings = nil
                    strongSelf.stateManager?.errorDidOccur(result.error as? NSError)
            }
        }
    }
    
    func saveSettings() {
        guard let settings = settings else {
            return
        }
        
        RequestOperation(request: DevicePreferencesRequest(preferences: settings.networkPreferences)).queue { [weak self] result in
            switch result {
                case .success(_), .cancelled:
                    break
                
                case .failure(_):
                    let title = NSLocalizedString("ErrorPushNotificationsNotSaved", comment: "")
                    let message = NSLocalizedString("PleaseTryAgainLater", comment: "")
                    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
                    self?.navigationController?.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func initializeSections() {
        sections = sectionsForTableView()
    }
    
    // MARK: - TableViewDataSource
    
    override func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier) as? VSettingsSwitchCell,
            let settings = self.settings
        ,
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
        cell.selectionStyle = .none
        
        if (indexPath.row == sections[indexPath.section].rows.count - 1) {
            cell.setSeparatorHidden(true)
        }
    
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
    
    override func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return settings == nil ? 0 : sections.count
    }
    
    override  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let dependencyManager = self.dependencyManager , section < sections.count else {
            return nil
        }
        let headerLabel = UILabel()
        headerLabel.text = sections[section].title
        headerLabel.font = dependencyManager.font(forKey: Constants.sectionTitleFontKey)
        headerLabel.textColor = dependencyManager.color(forKey: Constants.sectionTitleColorKey)
        headerLabel.sizeToFit()
        let headerContainer = UIView()
        headerContainer.addSubview(headerLabel)
        headerContainer.v_addFitToParentConstraints(toSubview: headerLabel, leading: Constants.tableViewHeaderLeftPadding, trailing: 0, top: 0, bottom: 0)
        return headerContainer
    }
    
    override  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.tableViewHeaderHeight
    }
    
    // MARK: - SettingsSwitchCell Delegate
    
    func settingsDidUpdatefromFromCell(_ cell: VSettingsSwitchCell, newValue: Bool, key: String) {
        guard var settings = self.settings else {
            return
        }
        settings.updateValue(forKey: key, newValue: newValue)
        self.settings = settings
        
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
        let items = dependencyManager.array(forKey: Constants.itemsArrayKey) ?? []
        
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
                        if (rowKey == NotificationSettingType.postFromCreator.rawValue) {
                            let appInfo = VAppInfo(dependencyManager: dependencyManager)
                            rowTitle = rowTitle.replacingOccurrences(of: Constants.creatorNameMacro, with: appInfo?.ownerName ?? "Creator")
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
    
    fileprivate func createErrorStateView() {
        if let errorStateView = dependencyManager?.createErrorStateView(actionType: .openSettings) {
            errorStateView.frame = CGRect(center: self.tableView.bounds.center, size: CGSize(width: Constants.errorStateViewWidthMultiplier * tableView.frame.width, height: Constants.errorStateViewHeight))
            self.errorStateView = errorStateView
        }
    }
    
    fileprivate func startSpinner() {
        view.addSubview(spinner)
        spinner.startAnimating()
    }
    
    fileprivate func stopSpinner() {
        spinner.stopAnimating()
        spinner.removeFromSuperview()
    }
    
    // MARK: - Dependency Manager
    
    class func new(with dependencyManager: VDependencyManager) -> NotificationSettingsViewController {
        let viewController = NotificationSettingsViewController(style: .grouped)
        viewController.dependencyManager = dependencyManager
        return viewController
    }
    
    func styleWithDependencyManager() {
        guard let dependencyManager = self.dependencyManager else {
            return
        }
        
        tableView.backgroundView = UIView()
        dependencyManager.addBackground(toBackgroundHost: self)
    }
}
