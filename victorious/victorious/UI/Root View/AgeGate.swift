//
//  AgeGate.swift
//  victorious
//
//  Created by Tian Lan on 12/8/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

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
        return NSUserDefaults.standardUserDefaults().boolForKey(DictionaryKeys.isAnonymousUser)
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
}
