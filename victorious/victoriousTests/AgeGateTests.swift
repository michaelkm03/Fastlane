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
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    private var isAgeGateEnabled: Bool {
        if let ageGateEnabled = NSBundle.mainBundle().objectForInfoDictionaryKey(DictionaryKeys.ageGateEnabled) as? String {
            return ageGateEnabled.lowercaseString == "yes"
        } else {
            return false
        }
    }

    private let originalValueForBirthdayProvided = AgeGate.hasBirthdayBeenProvided()
    private let originalValueForIsAnonymousUser = AgeGate.isAnonymousUser()

    override func tearDown() {
        super.tearDown()
        // Revert changes user default changes made by test cases
        userDefaults.setBool(originalValueForBirthdayProvided, forKey: DictionaryKeys.birthdayProvidedByUser)
        userDefaults.setBool(originalValueForIsAnonymousUser, forKey: DictionaryKeys.isAnonymousUser)
    }
    
    func testHasBirthdayBeenProvided() {
        userDefaults.setValue(false, forKey: DictionaryKeys.birthdayProvidedByUser)
        XCTAssertEqual(AgeGate.hasBirthdayBeenProvided(), isAgeGateEnabled)
        
        userDefaults.setValue(true, forKey: DictionaryKeys.birthdayProvidedByUser)
        XCTAssertEqual(AgeGate.hasBirthdayBeenProvided(), isAgeGateEnabled)
    }
    
    func testIsAnonymousUser() {
        userDefaults.setValue(false, forKey: DictionaryKeys.isAnonymousUser)
        XCTAssertEqual(AgeGate.isAnonymousUser(), isAgeGateEnabled)
        
        userDefaults.setValue(true, forKey: DictionaryKeys.isAnonymousUser)
        XCTAssertEqual(AgeGate.isAnonymousUser(), isAgeGateEnabled)
    }
    
    func testSaveShouldUserBeAnonymous() {
        AgeGate.saveShouldUserBeAnonymous(false)
        XCTAssertTrue(userDefaults.boolForKey(DictionaryKeys.birthdayProvidedByUser))
        XCTAssertEqual(AgeGate.isAnonymousUser(), isAgeGateEnabled)
        
        AgeGate.saveShouldUserBeAnonymous(true)
        XCTAssertTrue(userDefaults.boolForKey(DictionaryKeys.birthdayProvidedByUser))
        XCTAssertEqual(AgeGate.isAnonymousUser(), isAgeGateEnabled)
    }
    
    func testFilterTabMenuItems() {
        
        let inputItems = [
            VNavigationMenuItem(title: "foo", identifier: "foo", icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "bar", tintColor: UIColor()),
            VNavigationMenuItem(title: "Explore", identifier: "Menu Explore", icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "bar", tintColor: UIColor()),
            VNavigationMenuItem(title: "Explore2", identifier: "Menu Explore2", icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "bar", tintColor: UIColor()),
            VNavigationMenuItem(title: "fjdkslajkfld", identifier: "Menu asdf", icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "bar", tintColor: UIColor()),
            VNavigationMenuItem(title: "Channels", identifier: "Menu Channels", icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "bar", tintColor: UIColor()),
            VNavigationMenuItem(title: "following", identifier: "Menu following", icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "bar", tintColor: UIColor()),
            VNavigationMenuItem(title: "channel", identifier: "Menu channel", icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "bar", tintColor: UIColor()),
            VNavigationMenuItem(title: "home", identifier: "Menu home", icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "bar", tintColor: UIColor()),
            VNavigationMenuItem(title: "Home", identifier: "Menu Home", icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "bar", tintColor: UIColor())
        ]
        
        let outputItems = AgeGate.filterTabMenuItems(inputItems)
        XCTAssertEqual(outputItems.count, 3)
        XCTAssertEqual(outputItems[0].title, "Explore")
        XCTAssertEqual(outputItems[1].title, "Channels")
        XCTAssertEqual(outputItems[2].title, "Home")
    }
    
    func testFilterMultipleContainerItems() {
        let inputItems: [UIViewController] = [
            UIViewController(),
            VExploreViewController(),
            VDiscoverContainerViewController(),
            VUserProfileViewController()
        ]
        
        let outputItems = AgeGate.filterMultipleContainerItems(inputItems)
        XCTAssertEqual(outputItems.count, 3)
        XCTAssertFalse(outputItems.contains(VDiscoverContainerViewController()))
    }
    
    func testFilterMoreButtonItems() {
        let inputItems = [
            VActionItem.defaultActionItemWithTitle(NSLocalizedString("", comment: ""), actionIcon: UIImage(), detailText: ""),
            VActionItem.defaultActionItemWithTitle(NSLocalizedString("ha", comment: ""), actionIcon: UIImage(), detailText: ""),
            VActionItem.defaultActionItemWithTitle(NSLocalizedString("Repost", comment: ""), actionIcon: UIImage(), detailText: ""),
            VActionItem.defaultActionItemWithTitle(NSLocalizedString("Report", comment: ""), actionIcon: UIImage(), detailText: ""),
            VActionItem.defaultActionItemWithTitle(NSLocalizedString("Flag", comment: ""), actionIcon: UIImage(), detailText: ""),
            VActionItem.defaultActionItemWithTitle(NSLocalizedString("Report/Flag", comment: ""), actionIcon: UIImage(), detailText: "")
        ]
        
        let outputItems = AgeGate.filterMoreButtonItems(inputItems)
        XCTAssertEqual(outputItems.count, 1)
        XCTAssertEqual(outputItems[0].title, NSLocalizedString("Report/Flag", comment: ""))
    }
    
    func testFilterCommentCellUtilities() {
        let inputItems = [
            VUtilityButtonConfig(),
            VUtilityButtonConfig(),
            VUtilityButtonConfig(),
            VUtilityButtonConfig(),
            VUtilityButtonConfig()
        ]
        inputItems[0].type = .Delete
        inputItems[1].type = .Edit
        inputItems[2].type = .Flag
        inputItems[3].type = .Reply
        
        let outputItems = AgeGate.filterCommentCellUtilities(inputItems)
        XCTAssertEqual(outputItems.count, 1)
        XCTAssertEqual(outputItems[0].type, VCommentCellUtilityType.Flag)
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
            NSLocalizedString("ShareFacebook", comment: ""),
            NSLocalizedString("ShareTwitter", comment: ""),
            NSLocalizedString("ShareSMS", comment: ""),
            NSLocalizedString("", comment: ""),
            NSLocalizedString("Other string", comment: ""),
        ]
        
        let filteredActionItemNames = inputActionItemNames.filter() {
            AgeGate.isWebViewActionItemAllowed(forActionName: $0)
        }
        
        XCTAssertEqual(filteredActionItemNames.count, 2)
        XCTAssertEqual(filteredActionItemNames[0], NSLocalizedString("", comment: ""))
        XCTAssertEqual(filteredActionItemNames[1], NSLocalizedString("Other string", comment: ""))
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

private extension NSDate
{
    convenience init(dateString:String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let d = dateStringFormatter.dateFromString(dateString)!
        self.init(timeInterval:0, sinceDate:d)
    }
}
