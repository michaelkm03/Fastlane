//
//  AgeGate.swift
//  victorious
//
//  Created by Tian Lan on 12/8/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// A class responsible for Age gate related non-UI logics,
/// e.g. User defaults read/write, filtering array of app components for disabling.
/// Note: This class contains only static methods, it should not be instantiated in general
@objc class AgeGate: NSObject {
    
    private struct DictionaryKeys {
        static let birthdayProvidedByUser = "com.getvictorious.age_gate.birthday_provided"
        static let isAnonymousUser = "com.getvictorious.user.is_anonymous"
        static let ageGateEnabled = "IsAgeGateEnabled"
        static let anonymousUserID = "AnonymousAccountUserID"
        static let anonymousUserToken = "AnonymousAccountUserToken"
    }

    // MARK: - External dependencies with defaults

    static var userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
    static var authorizedMenuItemIdentifiers: [String] = ["Menu Home", "Menu Channels", "Menu Explore"]
    
    // MARK: - NSUserDefaults functions
    
    static func hasBirthdayBeenProvided() -> Bool {
        return isAgeGateEnabled() && AgeGate.userDefaults.boolForKey(DictionaryKeys.birthdayProvidedByUser)
    }
    
    static func isAnonymousUser() -> Bool {
        return isAgeGateEnabled() && AgeGate.userDefaults.boolForKey(DictionaryKeys.isAnonymousUser)
    }
    
    static func saveShouldUserBeAnonymous(anonymous: Bool) {
        AgeGate.userDefaults.setValue(true, forKey: DictionaryKeys.birthdayProvidedByUser)
        AgeGate.userDefaults.setValue(anonymous, forKey: DictionaryKeys.isAnonymousUser)
        AgeGate.userDefaults.synchronize()
    }
    
    // MARK: - Info.plist functions
    
    static func isAgeGateEnabled() -> Bool {
        if let ageGateEnabled = NSBundle.mainBundle().objectForInfoDictionaryKey(DictionaryKeys.ageGateEnabled) as? String {
            return ageGateEnabled.lowercaseString == "yes"
        } else {
            return false
        }
    }
    
    static func anonymousUserID() -> Int? {
        if let userIDFromPlist = NSBundle.mainBundle().objectForInfoDictionaryKey(DictionaryKeys.anonymousUserID) as? String,
            let userID = Int(userIDFromPlist) {
                return userID
        } else {
            return nil
        }
    }
    
    static func anonymousUserToken() -> String? {
        if let token = NSBundle.mainBundle().objectForInfoDictionaryKey(DictionaryKeys.anonymousUserToken) as? String {
            return token
        } else {
            return nil
        }
    }
    
    // MARK: - Feature Disabling functions
    
    static func filterTabMenuItems(menuItems: [VNavigationMenuItem]) -> [VNavigationMenuItem] {
        return menuItems.filter() { AgeGate.authorizedMenuItemIdentifiers.contains($0.identifier) }
    }
    
    static func filterMoreButtonItems(items: [VActionItem]) -> [VActionItem] {
        return items.filter() { $0.title == NSLocalizedString("Report/Flag", comment: "") || $0.type != VActionItemType.Default }
    }
    
    static func isAccessoryItemAllowed(accessoryItem: VNavigationMenuItem) -> Bool {
        let accessoryItemBlackList = [
            VDependencyManagerAccessoryItemMenu,
            VDependencyManagerAccessoryItemCompose,
            VDependencyManagerAccessoryItemInbox,
            VDependencyManagerAccessoryItemFindFriends,
            VDependencyManagerAccessoryItemInvite,
            VDependencyManagerAccessoryItemCreatePost,
            VDependencyManagerAccessoryItemFollowHashtag,
            VDependencyManagerAccessoryItemMore,
            VDependencyManagerAccessoryNewMessage,
            VDependencyManagerAccessorySettings
        ]
        return !accessoryItemBlackList.contains(accessoryItem.identifier)
    }
    
    static func isTrackingEventAllowed(forEventName eventName: String) -> Bool {
        let trackingEventsWhiteList = [
            VTrackingEventApplicationFirstInstall,
            VTrackingEventApplicationDidLaunch,
            VTrackingEventApplicationDidEnterForeground,
            VTrackingEventApplicationDidEnterBackground
        ]
        return trackingEventsWhiteList.contains(eventName)
    }
    
    static func isWebViewActionItemAllowed(forActionName actionName: String) -> Bool {
        let actionItemBlackList = [
            NSLocalizedString("ShareFacebook", comment: ""),
            NSLocalizedString("ShareTwitter", comment: ""),
            NSLocalizedString("ShareSMS", comment: "")
        ]
        return !actionItemBlackList.contains(actionName)
    }
    
    // MARK: - Age Gate Business Logic functions
    
    static func isUserYoungerThan(age: Int, forBirthday birthday: NSDate) -> Bool {
        let now = NSDate()
        let ageComponents = NSCalendar.currentCalendar().components(.Year, fromDate: birthday, toDate: now, options: NSCalendarOptions())
        return ageComponents.year < age
    }
    
    static func decorateTemplateForLegalInfoAccessoryButton(templateDecorator: VTemplateDecorator) {
        let keyPath = "scaffold/menu/items/0/accessoryScreens"
        let navigationBarItemTextColor = templateDecorator.templateValueForKeyPath("scaffold/navigationBarAppearance/\(VDependencyManagerMainTextColorKey)")
        let accessoryButtonConfig = [
            "title": "Legal Information",
            "icon": [
                "imageURL": "OverFlowIcon"
            ],
            "selectedIcon": [
                "imageURL": "OverFlowIcon"
            ],
            "identifier": "Accessory Legal Information",
            "position": "right",
            "color.text": navigationBarItemTextColor
        ]
        
        var accessoryItems = templateDecorator.templateValueForKeyPath(keyPath) as? [[String: AnyObject]] ?? []
        accessoryItems.append(accessoryButtonConfig)
        
        templateDecorator.setTemplateValue(accessoryItems, forKeyPath: keyPath)
    }
}
