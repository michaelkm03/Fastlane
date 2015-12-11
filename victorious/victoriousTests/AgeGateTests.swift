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
    
    func testHasBirthdayBeenProvided() {
        userDefaults.setValue(false, forKey: DictionaryKeys.birthdayProvidedByUser)
        XCTAssertFalse(AgeGate.hasBirthdayBeenProvided())
        
        userDefaults.setValue(true, forKey: DictionaryKeys.birthdayProvidedByUser)
        XCTAssertTrue(AgeGate.hasBirthdayBeenProvided())
    }
    
    func testIsAnonymousUser() {
        userDefaults.setValue(false, forKey: DictionaryKeys.isAnonymousUser)
        XCTAssertFalse(AgeGate.isAnonymousUser())
        
        userDefaults.setValue(true, forKey: DictionaryKeys.isAnonymousUser)
        XCTAssertTrue(AgeGate.isAnonymousUser())
    }
    
    func testSaveShouldUserBeAnonymous() {
        AgeGate.saveShouldUserBeAnonymous(false)
        XCTAssertTrue(userDefaults.boolForKey(DictionaryKeys.birthdayProvidedByUser))
        XCTAssertFalse(AgeGate.isAnonymousUser())
        
        AgeGate.saveShouldUserBeAnonymous(true)
        XCTAssertTrue(userDefaults.boolForKey(DictionaryKeys.birthdayProvidedByUser))
        XCTAssertTrue(AgeGate.isAnonymousUser())
    }
    
    func testFilterTabMenuItems() {
        
        let inputItems = [
            VNavigationMenuItem(title: "", identifier: "foo", icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "bar", tintColor: UIColor()),
            VNavigationMenuItem(title: "Explore", identifier: "foo", icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "bar", tintColor: UIColor()),
            VNavigationMenuItem(title: "Explore2", identifier: "foo", icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "bar", tintColor: UIColor()),
            VNavigationMenuItem(title: "fjdkslajkfld", identifier: "foo", icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "bar", tintColor: UIColor()),
            VNavigationMenuItem(title: "Channels", identifier: "foo", icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "bar", tintColor: UIColor()),
            VNavigationMenuItem(title: "following", identifier: "foo", icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "bar", tintColor: UIColor()),
            VNavigationMenuItem(title: "channel", identifier: "foo", icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "bar", tintColor: UIColor()),
            VNavigationMenuItem(title: "home", identifier: "foo", icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "bar", tintColor: UIColor()),
            VNavigationMenuItem(title: "Home", identifier: "foo", icon: UIImage(), selectedIcon: UIImage(), destination: UIViewController(), position: "bar", tintColor: UIColor())
        ]
        
        let outputItems = AgeGate.filterTabMenuItems(inputItems)
        XCTAssertEqual(outputItems.count, 3)
        XCTAssertEqual(outputItems[0].title, "Explore")
        XCTAssertEqual(outputItems[1].title, "Channels")
        XCTAssertEqual(outputItems[2].title, "Home")
    }
    
    func testFilterMultipleContainerItems() {
        let inputItems:[UIViewController] = [
            UIViewController(),
            VExploreViewController(),
            VDiscoverContainerViewController(),
            VUserProfileViewController()
        ]
        
        let outputItems = AgeGate.filterMultipleContainerItems(inputItems)
        XCTAssertEqual(outputItems.count, 3)
        XCTAssertFalse(outputItems.contains(VDiscoverContainerViewController()))
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
