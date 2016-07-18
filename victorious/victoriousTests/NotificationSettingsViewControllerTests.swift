//
//  NotificationSettingsViewControllerTests.swift
//  victorious
//
//  Created by Darvish Kamalia on 6/28/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class NotificationSettingsViewControllerTests: XCTestCase {
    func createTestDependencyManager() -> VDependencyManager {
        return VDependencyManager(
            parentManager: nil,
            configuration: [
                "items" : [
                    [
                        "section.title" : "First Section",
                        "section.items" : [
                            [
                                "title" : "First row",
                                "key" : "First key"
                            ],
                            [
                                "title" : "Second row",
                                "key" : "Second key"
                            ]
                        ]
                    ],
                    [
                        "section.title" : "Second Section",
                        "section.items" : [
                            [
                                "title" : "First row",
                                "key" : "First key"
                            ]
                        ]
                    ]
                ]
            ],
            dictionaryOfClassesByTemplateName: nil
        )
    }

    func testParsing() {
        let viewController = NotificationSettingsViewController.newWithDependencyManager(createTestDependencyManager())
        let sections = viewController.sectionsForTableView()
        XCTAssertEqual(sections.count, 2)
        
        let firstSection = sections[0]
        XCTAssertEqual(firstSection.title, "First Section")
        XCTAssertEqual(firstSection.rows.count, 2)
        
        let firstRow = firstSection.rows[0]
        XCTAssertEqual(firstRow.title, "First row")
    }
}
