//
//  AgeGateTests.swift
//  victorious
//
//  Created by Tian Lan on 12/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class AgeGateTests: XCTestCase {
    private struct DictionaryKeys {
        static let birthdayProvidedByUser = "com.getvictorious.age_gate.birthday_provided"
        static let isAnonymousUser = "com.getvictorious.user.is_anonymous"
        static let ageGateEnabled = "IsAgeGateEnabled"
        static let anonymousUserID = "AnonymousAccountUserID"
        static let anonymousUserToken = "AnonymousAccountUserToken"
    }
    
    let testUserDefaults = NSUserDefaults()

    private var isAgeGateEnabled: Bool {
        if let ageGateEnabled = NSBundle.mainBundle().objectForInfoDictionaryKey(DictionaryKeys.ageGateEnabled) as? String {
            return ageGateEnabled.lowercaseString == "yes"
        } else {
            return false
        }
    }

    private let originalValueForBirthdayProvided = AgeGate.hasBirthdayBeenProvided()
    private let originalValueForIsAnonymousUser = AgeGate.isAnonymousUser()
    
    override func setUp() {
        super.setUp()
        
        // Swap out the default standard user defaults for ours
        AgeGate.userDefaults = self.testUserDefaults
    }
    
    func testHasBirthdayBeenProvided() {
        testUserDefaults.setValue(false, forKey: DictionaryKeys.birthdayProvidedByUser)
        XCTAssertEqual(AgeGate.hasBirthdayBeenProvided(), isAgeGateEnabled)
        
        testUserDefaults.setValue(true, forKey: DictionaryKeys.birthdayProvidedByUser)
        XCTAssertEqual(AgeGate.hasBirthdayBeenProvided(), isAgeGateEnabled)
    }
    
    func testIsAnonymousUser() {
        testUserDefaults.setValue(false, forKey: DictionaryKeys.isAnonymousUser)
        XCTAssertEqual(AgeGate.isAnonymousUser(), isAgeGateEnabled)
        
        testUserDefaults.setValue(true, forKey: DictionaryKeys.isAnonymousUser)
        XCTAssertEqual(AgeGate.isAnonymousUser(), isAgeGateEnabled)
    }
    
    func testSaveShouldUserBeAnonymous() {
        AgeGate.saveShouldUserBeAnonymous(false)
        XCTAssertTrue(testUserDefaults.boolForKey(DictionaryKeys.birthdayProvidedByUser))
        XCTAssertEqual(AgeGate.isAnonymousUser(), isAgeGateEnabled)
        
        AgeGate.saveShouldUserBeAnonymous(true)
        XCTAssertTrue(testUserDefaults.boolForKey(DictionaryKeys.birthdayProvidedByUser))
        XCTAssertEqual(AgeGate.isAnonymousUser(), isAgeGateEnabled)
    }
    
    func testFilterTabMenuItems() {
        let inputItems = [
            VNavigationMenuItem(title: "", identifier: "foo", icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "bar", tintColor: UIColor()),
            VNavigationMenuItem(title: "Explore", identifier: "Explore", icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "bar", tintColor: UIColor()),
            VNavigationMenuItem(title: "Explore2", identifier: "Explore2", icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "bar", tintColor: UIColor()),
            VNavigationMenuItem(title: "Fjdkslajkfld", identifier: "Fjdkslajkfld", icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "bar", tintColor: UIColor()),
            VNavigationMenuItem(title: "Channels", identifier: "Channels", icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "bar", tintColor: UIColor()),
            VNavigationMenuItem(title: "Following", identifier: "Following", icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "bar", tintColor: UIColor()),
            VNavigationMenuItem(title: "Channel", identifier: "Channel", icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "bar", tintColor: UIColor()),
            VNavigationMenuItem(title: "Home", identifier: "Home", icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "bar", tintColor: UIColor())
        ]
        
        AgeGate.authorizedMenuItemIdentifiers = ["Home", "Channels", "Explore"]
        let expectedCount = 3

        let outputItems = AgeGate.filterTabMenuItems(inputItems)
        XCTAssertEqual(outputItems.count, expectedCount)
        if outputItems.count > expectedCount {
            XCTAssertEqual(outputItems[0].title, "Explore")
            XCTAssertEqual(outputItems[1].title, "Channels")
            XCTAssertEqual(outputItems[2].title, "Home")
        }
    }
    
    func testFilterMoreButtonItems() {
        let inputItems = [
            VActionItem.defaultActionItemWithTitle("", actionIcon: UIImage(), detailText: ""),
            VActionItem.defaultActionItemWithTitle("ha", actionIcon: UIImage(), detailText: ""),
            VActionItem.defaultActionItemWithTitle("Repost", actionIcon: UIImage(), detailText: ""),
            VActionItem.defaultActionItemWithTitle("Report", actionIcon: UIImage(), detailText: ""),
            VActionItem.defaultActionItemWithTitle("Flag", actionIcon: UIImage(), detailText: ""),
            VActionItem.defaultActionItemWithTitle("Report/Flag", actionIcon: UIImage(), detailText: "")
        ]
        
        let outputItems = AgeGate.filterMoreButtonItems(inputItems)
        XCTAssertEqual(outputItems.count, 1)
        XCTAssertEqual(outputItems[0].title, "Report/Flag")
    }
    
    func testIsTrackingEventAllowed() {
        let inputTrackingEvents = [
            "abc",
            VTrackingEventApplicationDidEnterBackground,
            "awesome tracking event name",
            VTrackingEventApplicationDidEnterForeground,
            VTrackingEventAppStoreProductRequestDidFail,
            VTrackingEventCameraDidCaptureVideo,
            VTrackingEventApplicationDidLaunch,
            VTrackingEventVideoDidComplete25,
            VTrackingEventApplicationFirstInstall,
            ""
        ]
        
        let outputTrackingEvents = inputTrackingEvents.filter() {
            AgeGate.isTrackingEventAllowed(forEventName: $0)
        }
        
        XCTAssertEqual(outputTrackingEvents.count, 4)
        XCTAssertEqual(outputTrackingEvents[0], VTrackingEventApplicationDidEnterBackground)
        XCTAssertEqual(outputTrackingEvents[1], VTrackingEventApplicationDidEnterForeground)
        XCTAssertEqual(outputTrackingEvents[2], VTrackingEventApplicationDidLaunch)
        XCTAssertEqual(outputTrackingEvents[3], VTrackingEventApplicationFirstInstall)
    }
    
    func testIsAccessoryItemAllowed() {
        let inputAccessoryItems: [VNavigationMenuItem] = [
            VNavigationMenuItem(title: "title", identifier: "onlySurvivor", icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "", tintColor: UIColor()),
            VNavigationMenuItem(title: "title", identifier: VDependencyManagerAccessoryItemMenu, icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "", tintColor: UIColor()),
            VNavigationMenuItem(title: "title", identifier: VDependencyManagerAccessoryItemCompose, icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "", tintColor: UIColor()),
            VNavigationMenuItem(title: "title", identifier: VDependencyManagerAccessoryItemInbox, icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "", tintColor: UIColor()),
            VNavigationMenuItem(title: "title", identifier: VDependencyManagerAccessoryItemFindFriends, icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "", tintColor: UIColor()),
            VNavigationMenuItem(title: "title", identifier: VDependencyManagerAccessoryItemInvite, icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "", tintColor: UIColor()),
            VNavigationMenuItem(title: "title", identifier: VDependencyManagerAccessoryItemCreatePost, icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "", tintColor: UIColor()),
            VNavigationMenuItem(title: "title", identifier: VDependencyManagerAccessoryItemFollowHashtag, icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "", tintColor: UIColor()),
            VNavigationMenuItem(title: "title", identifier: VDependencyManagerAccessoryItemInbox, icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "", tintColor: UIColor()),
            VNavigationMenuItem(title: "title", identifier: VDependencyManagerAccessoryItemMore, icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "", tintColor: UIColor()),
            VNavigationMenuItem(title: "title", identifier: VDependencyManagerAccessoryNewMessage, icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "", tintColor: UIColor()),
            VNavigationMenuItem(title: "title", identifier: VDependencyManagerAccessorySettings, icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "", tintColor: UIColor())
        ]
        
        let filteredAccessoryItems = inputAccessoryItems.filter() {
            AgeGate.isAccessoryItemAllowed($0)
        }
        
        XCTAssertEqual(filteredAccessoryItems.count, 1)
        XCTAssertEqual(filteredAccessoryItems[0].identifier, "onlySurvivor")
    }
    
    func testIsWebViewActionItemAllowed() {
        let inputActionItemNames: [String] = [
            "Share to Facebook",
            "Share to Twitter",
            "Send as Text",
            "",
            "Other string",
        ]
        
        let filteredActionItemNames = inputActionItemNames.filter() {
            AgeGate.isWebViewActionItemAllowed(forActionName: $0)
        }
        
        XCTAssertEqual(filteredActionItemNames.count, 2)
        XCTAssertEqual(filteredActionItemNames[0], "")
        XCTAssertEqual(filteredActionItemNames[1], "Other string")
    }
    
    func testIsUserYoungerThan() {
        let targetAge = 13
        let oldManBirthday = NSDate(dateString: "1944-05-13")
        let childBirthday = NSDate(dateString: "2010-05-05")
        let today = NSDate()
        
        XCTAssertFalse(AgeGate.isUserYoungerThan(targetAge, forBirthday: oldManBirthday))
        XCTAssertTrue(AgeGate.isUserYoungerThan(targetAge, forBirthday: childBirthday))
        XCTAssertTrue(AgeGate.isUserYoungerThan(targetAge, forBirthday: today))
    }
}

private extension NSDate {
    convenience init(dateString: String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let d = dateStringFormatter.dateFromString(dateString)!
        self.init(timeInterval: 0, sinceDate: d)
    }
}
