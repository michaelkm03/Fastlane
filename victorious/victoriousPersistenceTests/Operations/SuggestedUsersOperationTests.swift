//
//  SuggestedUsersOperationTests.swift
//  victorious
//
//  Created by Tian Lan on 11/24/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
@testable import victorious

class SuggestedUsersOperationTests: BaseFetcherOperationTestCase {
    
    var operation: SuggestedUsersOperation!

    override func setUp() {
        super.setUp()
        continueAfterFailure = true
        
        operation = SuggestedUsersOperation()
    }
    
    func testSuccess() {
        guard let suggestedUser = createSuggestedUser() else {
            XCTFail("Failed to create suggested user for testing." )
            return
        }
        
        testRequestExecutor = TestRequestExecutor(result:[suggestedUser])
        operation.requestExecutor = testRequestExecutor
        
        let expectation = expectationWithDescription("SuggestedUsersOperation")
        operation.queue() { results, error, cancelled in
            
            XCTAssertEqual( self.testRequestExecutor.executeRequestCallCount, 1 )
            XCTAssertEqual(1, self.testRequestExecutor.executeRequestCallCount)
            if let fetchedUsers = self.operation.results as? [VSuggestedUser] {
                XCTAssertEqual(1, fetchedUsers.count)
                XCTAssertEqual(1, fetchedUsers[0].recentSequences.count)
                XCTAssertEqual(suggestedUser.user.id, fetchedUsers[0].user.remoteId)
            } else {
                XCTFail("operation didn't fetch any suggested users")
            }
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
    
    private func createSuggestedUser() -> SuggestedUser? {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("User", withExtension: "json"),
            let mockUserData = NSData(contentsOfURL: mockUserDataURL),
            let user = User(json: JSON(data: mockUserData)),
            let sequence = createSequence() else {
                return nil
        }
        return SuggestedUser(user: user, recentSequences: [sequence])
    }
    
    private func createSequence() -> Sequence? {
        guard let sequenceUrl = NSBundle(forClass: self.dynamicType).URLForResource("Sequence", withExtension: "json" ),
            let mockSequenceData = NSData(contentsOfURL: sequenceUrl) else {
                return nil
        }
        return Sequence(json: JSON(data: mockSequenceData))
    }
}
