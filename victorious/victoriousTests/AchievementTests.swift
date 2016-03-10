//
//  AchievementTests.swift
//  victorious
//
//  Created by Tian Lan on 3/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious
class AchievementTests: XCTestCase {
    
    private let testIdentifier = "test_identifier"
    private let testTitle = "testTitle"
    private let testDescription = "testDescription"
    private let testDisplayOrder = 2016
    private let testUnlockedIconImageURL = "http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/fanclub/icons/shared/badge_following_ten.png"
    private let testLockedIconImageURL = "http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/fanclub/icons/shared/badge_locked.png"
    
    func testAchievementInitialization() {
        let testConfiguration: [NSObject : AnyObject] = [
            "identifier" : testIdentifier,
            "title" : testTitle,
            "description" : testDescription,
            "display_order" : testDisplayOrder,
            "assets" : [
                "imageSet" : [
                    [
                        "imageURL" : testUnlockedIconImageURL,
                        "scale" : 1
                    ],
                    [
                        "imageURL" : testUnlockedIconImageURL,
                        "scale" : 2
                    ],
                    [
                        "imageURL" : testUnlockedIconImageURL,
                        "scale" : 3
                    ],
                ]
            ],
            "locked_icon" : [
                "imageSet" : [
                    [
                        "imageURL" : testLockedIconImageURL,
                        "scale" : 1
                    ],
                    [
                        "imageURL" : testLockedIconImageURL,
                        "scale" : 2
                    ],
                    [
                        "imageURL" : testLockedIconImageURL,
                        "scale" : 3
                    ],
                ]
            ],
        ]
        
        let dependencyManager: VDependencyManager = VDependencyManager(
            parentManager: nil,
            configuration: testConfiguration,
            dictionaryOfClassesByTemplateName: nil)
        
        guard let achievement: Achievement = Achievement(dependencyManager: dependencyManager) else {
            XCTFail("initialization failed")
            return
        }
        
        XCTAssertEqual(achievement.title, testTitle)
        XCTAssertEqual(achievement.detailedDescription, testDescription)
        XCTAssertEqual(achievement.displayOrder, testDisplayOrder)
        XCTAssertNotNil(achievement.iconImage)
        XCTAssertFalse(achievement.isUnlocked)
    }
}
