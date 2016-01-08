//
//  SuggestedUsersOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 11/24/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
import SwiftyJSON
@testable import victorious

class SuggestedUsersOperationTests: XCTestCase {
    let expectationThreshold: Double = 10
    var operation: SuggestedUsersOperation!
    var testStore: TestPersistentStore!
    var testRequestExecutor: TestRequestExecutor!
    let operationHelper = RequestOperationTestHelper()

    override func setUp() {
        super.setUp()
        continueAfterFailure = true
        testStore = TestPersistentStore()
        operation = SuggestedUsersOperation()
        testRequestExecutor = TestRequestExecutor()
        operation.persistentStore = testStore
        operation.requestExecutor = testRequestExecutor
    }

    func testGetSuggestedUsers() {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("User", withExtension: "json"),
            let mockUserData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        guard let user = User(json: JSON(data: mockUserData)) else {
            XCTFail("User initializer failed")
            return
        }

        guard let sequenceUrl = NSBundle(forClass: self.dynamicType).URLForResource("Sequence", withExtension: "json" ),
            let mockSequenceData = NSData(contentsOfURL: sequenceUrl) else {
                XCTFail("Error reading mock json data" )
                return
        }
        guard let sequence = Sequence(json: JSON(data: mockSequenceData)) else {
            XCTFail("Sequence initializer failed" )
            return
        }

        let suggestedUser = SuggestedUser(user: user, recentSequences: [sequence])
        testRequestExecutor.onCompleteResult = [suggestedUser]

        operation.main()

        XCTAssertEqual(1, testRequestExecutor.executeRequestCallCount)
        if let fetchedUsers = operation.results as? [VSuggestedUser] {
            XCTAssertEqual(1, fetchedUsers.count)
            XCTAssertEqual(1, fetchedUsers[0].recentSequences.count)
            XCTAssertEqual(suggestedUser.user.userID, fetchedUsers[0].user.remoteId)
        } else {
            XCTFail("operation didn't fetch any suggested users")
        }
    }
}
