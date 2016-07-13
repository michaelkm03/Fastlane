//
//  StageMetaDataTests.swift
//  victorious
//
//  Created by Sebastian Nystorm on 13/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import VictoriousIOSSDK

class StageMetaDataTests: XCTestCase {

    private let testTitle = "Teh Stage"
    private let testDescription = "Description text"

    func testInitialiation() {
        guard let author = loadUser() else {
            XCTFail("Failed to create test User.")
            return
        }

        let content = Content(id: "1337", createdAt: NSDate(), type: .image, text: testDescription, assets: [], previewImages: [], author: author)

        var metaData = StageMetaData(title: testTitle)
        metaData.populateWith(content)

        XCTAssertEqual(metaData.title, testTitle)
        XCTAssertEqual(metaData.description, testDescription)
    }

    private func loadUser() -> User? {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("User", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                return nil
        }
        return User(json: JSON(data: mockData))
    }
}
