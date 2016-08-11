//
//  VUserTests.swift
//  victorious
//
//  Created by Vincent Ho on 5/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import VictoriousIOSSDK
@testable import victorious

class VUserTests: BasePersistentStoreTestCase {
    func testValid() {
        guard let user: VUser = createUserFromJSON(fileName: "User") else {
            XCTFail("Failed to create a VUser")
            return
        }
        XCTAssertEqual(user.remoteId, 36179)
        XCTAssertEqual(user.username, "tyt@creator.us")
        XCTAssertEqual(user.displayName, "The Young Turks")
        XCTAssertEqual(user.isCreator, true)
        XCTAssertEqual(user.location, "Fargo, ND")
        XCTAssertEqual(user.tagline, "My coolest tagline")
        XCTAssertEqual(user.levelProgressPoints, Int(2764))
        XCTAssertEqual(user.likesGiven, 99)
        XCTAssertEqual(user.likesReceived, 40)
        XCTAssertEqual(user.isVIPSubscriber, 1)
        XCTAssertEqual(user.previewAssets?.count, 2)
    }
    
    private func createUserFromJSON(fileName fileName: String) -> VUser? {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource(fileName, withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return nil
        }
        
        guard let user = User(json: JSON(data: mockData)) else {
            XCTFail("Error reading mock json data")
            return nil
        }
        let persistentSequenceModel: VUser = persistentStoreHelper.createUser(remoteId: 1)
        persistentSequenceModel.populate(fromSourceModel: user)
        return persistentSequenceModel
    }
}
