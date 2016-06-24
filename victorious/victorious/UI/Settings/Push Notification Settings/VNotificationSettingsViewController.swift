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
        
        //        // Feed section
        //        NSString *format = NSLocalizedString( @"PostFromCreator", nil);
        //        VAppInfo *appInfo = [[VAppInfo alloc] initWithDependencyManager:self.dependencyManager];
        //        NSString *creatorName = appInfo.ownerName;
        //        NSArray *sectionFeedRows = @[ [[VNotificationSettingsTableRow alloc] initWithTitle:[NSString stringWithFormat:format, creatorName]
        //        enabled:_settings.isPostFromCreatorEnabled.boolValue],
        //        [[VNotificationSettingsTableRow alloc] initWithTitle:NSLocalizedString( @"PostFromFollowed", nil)
        //        enabled:_settings.isPostFromFollowedEnabled.boolValue],
        //        [[VNotificationSettingsTableRow alloc] initWithTitle:NSLocalizedString( @"NewComment", nil)
        //        enabled:_settings.isNewCommentOnMyPostEnabled.boolValue],
        //        [[VNotificationSettingsTableRow alloc] initWithTitle:NSLocalizedString( @"PostOnFollowedHashTag", nil)
        //        enabled:_settings.isPostOnFollowedHashTagEnabled.boolValue]];
        //        NSString *sectionFeedTitle = NSLocalizedString( @"NotificationSettingSectionFeeds", nil);
        //        VNotificationSettingsTableSection *sectionFeed = [[VNotificationSettingsTableSection alloc] initWithTitle:sectionFeedTitle
        //        rows:sectionFeedRows ];
        //
        //        // People Section
        //        NSArray *sectionPeopleRows = @[ [[VNotificationSettingsTableRow alloc] initWithTitle:NSLocalizedString( @"NewPrivateMessage", nil)
        //        enabled:_settings.isNewPrivateMessageEnabled.boolValue],
        //        [[VNotificationSettingsTableRow alloc] initWithTitle:NSLocalizedString( @"NewFollower", nil)
        //        enabled:_settings.isNewFollowerEnabled.boolValue],
        //        [[VNotificationSettingsTableRow alloc] initWithTitle:NSLocalizedString( @"TagInComment", nil)
        //        enabled:_settings.isUserTagInCommentEnabled.boolValue],
        //        [[VNotificationSettingsTableRow alloc] initWithTitle:NSLocalizedString( @"LikePost", nil)
        //        enabled:_settings.isPeopleLikeMyPostEnabled.boolValue]];
        //        NSString *sectionPeopleTitle = NSLocalizedString( @"NotificationSettingSectionPeople", nil);
        //        VNotificationSettingsTableSection *sectionPeople = [[VNotificationSettingsTableSection alloc] initWithTitle:sectionPeopleTitle
        //        rows:sectionPeopleRows ];
        //
        //        // Add both sections
        //        self.sections = [[NSOrderedSet alloc] initWithObjects: sectionFeed, sectionPeople, nil];
        
        //self.sections = dependencyManager.sectionsForTableView()
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
    
    public func backgroundContainerView() -> UIView {
        return tableView.backgroundView ?? self.view
    }
    
    func updateSettings() {
        let settings = self.getSettings()
        settings.isPostFromCreatorEnabled = isSettingEnabled(.postFromCreator)
//        self.settings.isPostFromCreatorEnabled = @( [section rowAtIndex: dependencyManager.indexPathForSettingType(VNotificationSettingType.isPostCreator)].isEnabled );
//        self.settings.isPostFromFollowedEnabled = @( [section rowAtIndex:1].isEnabled );
//        self.settings.isNewCommentOnMyPostEnabled = @( [section rowAtIndex:2].isEnabled );
//        self.settings.isPostOnFollowedHashTagEnabled = @( [section rowAtIndex:3].isEnabled );
//        section = self.sections[ 1 ];
//        self.settings.isNewPrivateMessageEnabled = @( [section rowAtIndex:0].isEnabled );
//        self.settings.isNewFollowerEnabled = @( [section rowAtIndex:1].isEnabled );
//        self.settings.isUserTagInCommentEnabled = @( [section rowAtIndex:2].isEnabled );
//        self.settings.isPeopleLikeMyPostEnabled = @( [section rowAtIndex:3].isEnabled );
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
    
    private func isSettingEnabled(type: VNotificationSettingType) -> Bool{
        sections.enumerateObjectsUsingBlock { (section, _, _) in
            if let sectionArray = section as? NSArray {
                sectionArray.enumerateObjectsUsingBlock({ (row, _, _) in
                    if let tableRow = row as? VNotificationSettingsTableRow where row.key == type.rawValue {
                        return row.isEnabled
                    }
                })
            }
        }
        
        return false 
    }
    
}

