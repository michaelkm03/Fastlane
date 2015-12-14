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
    
    //MARK: - NSUserDefaults functions
    
    static func hasBirthdayBeenProvided() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(DictionaryKeys.birthdayProvidedByUser)
    }
    
    static func isAnonymousUser() -> Bool {
        //TODO: The following VObjectManager line is for testing before user -1 is authroized on the backend. Remove before merging.
        return VObjectManager.sharedManager().mainUserLoggedIn
//        return NSUserDefaults.standardUserDefaults().boolForKey(DictionaryKeys.isAnonymousUser)
    }
    
    static func saveShouldUserBeAnonymous(anonymous: Bool) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue(true, forKey: DictionaryKeys.birthdayProvidedByUser)
        userDefaults.setValue(anonymous, forKey: DictionaryKeys.isAnonymousUser)
        userDefaults.synchronize()
    }
    
    //MARK: - Info.plist functions
    
    static func isAgeGateEnabled() -> Bool {
        if let ageGateEnabled = NSBundle.mainBundle().objectForInfoDictionaryKey(DictionaryKeys.ageGateEnabled) as? String {
            return ageGateEnabled.lowercaseString == "yes"
        } else {
            return false
        }
    }
    
    static func anonymousUserID() -> String? {
        if let userID = NSBundle.mainBundle().objectForInfoDictionaryKey(DictionaryKeys.anonymousUserID) as? String {
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
    
    //MARK: - Feature Disabling functions
    
    static func filterTabMenuItems(menuItems: [VNavigationMenuItem]) -> [VNavigationMenuItem] {
        return menuItems.filter() { ["Home", "Channels", "Explore"].contains($0.title) }
    }
    
    static func filterMultipleContainerItems(containerChilds: [UIViewController]) -> [UIViewController] {
        return containerChilds.filter() { !$0.isKindOfClass(VDiscoverContainerViewController) }
    }
    
    static func filterMoreButtonItems(items: [VActionItem]) -> [VActionItem] {
        return items.filter() { $0.title == NSLocalizedString("Report/Flag", comment: "") || $0.type != VActionItemType.Default }
    }
    
    static func filterCommentCellUtilities(utilities: [VUtilityButtonConfig]) -> [VUtilityButtonConfig] {
        return utilities.filter() { $0.type == .Flag }
    }
    
    static func isTrackingEventAllowed(forEventName eventName: String) -> Bool {
        let allowedTrackingEvents = [
            VTrackingEventApplicationFirstInstall,
            VTrackingEventApplicationDidLaunch,
            VTrackingEventApplicationDidEnterForeground,
            VTrackingEventApplicationDidEnterBackground
        ]
        return allowedTrackingEvents.contains(eventName)
    }
    
    //MARK: - Age Gate Business Logic functions
    
    static func isUserYoungerThan(age: Int, forBirthday birthday: NSDate) -> Bool {
        let now = NSDate()
        let ageComponents = NSCalendar.currentCalendar().components(.Year, fromDate: birthday, toDate: now, options: NSCalendarOptions())
        return ageComponents.year < 13
    }
}
