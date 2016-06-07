//
//  ShowTutorialsOperationTests.swift
//  victorious
//
//  Created by Michael Sena on 5/31/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest

@testable import victorious

class ShowTutorialsOperationTests: XCTestCase {
    
    func test() {

        let viewController = UIViewController()
        let dependencyManager = VDependencyManager(parentManager: nil, configuration: nil, dictionaryOfClassesByTemplateName: nil)
        let showTutorialOperation = ShowTutorialsOperation(originViewController: viewController, dependencyManager: dependencyManager)
        var userDefaults = NSUserDefaults(suiteName: NSUUID().UUIDString)!
        
        // We should only show the turorial post 5.0.
        XCTAssertFalse(showTutorialOperation.shouldShowTutorials(AppVersion(versionNumber: "4.0"), userDefaults: userDefaults))
        
        // We should show the first time a 5.0 user enters but not the second time.
        XCTAssertTrue(showTutorialOperation.shouldShowTutorials(AppVersion(versionNumber: "5.0"), userDefaults: userDefaults))
        XCTAssertFalse(showTutorialOperation.shouldShowTutorials(AppVersion(versionNumber: "5.0"), userDefaults: userDefaults))

        userDefaults = NSUserDefaults(suiteName: NSUUID().UUIDString)!
        // For users that start in a 5.X world We should show if they have never seen it.
        XCTAssertTrue(showTutorialOperation.shouldShowTutorials(AppVersion(versionNumber: "5.1"), userDefaults: userDefaults))
        
        // But not from release to release (unless this changes in the future).
        XCTAssertFalse(showTutorialOperation.shouldShowTutorials(AppVersion(versionNumber: "5.2"), userDefaults: userDefaults))
    }
}
