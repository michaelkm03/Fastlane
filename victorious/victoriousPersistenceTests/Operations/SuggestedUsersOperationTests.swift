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
    
    func testOnComplete() {
        // Generate valid suggested users data
        var requestResults: SuggestedUsersRequest.ResultType = []
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("SuggestedUsersResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let suggestedUsersRequest = SuggestedUsersRequest()
            requestResults = try suggestedUsersRequest.parseResponse(NSURLResponse(), toRequest: suggestedUsersRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }

        // Feed the request results to operation's onComplete function
        let operation = SuggestedUsersOperation()
        
        let expectation = expectationWithDescription("load users")
        operation.onComplete(requestResults) {
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout( 2, handler: nil)
        
        guard let suggestedUsers = operation.results as? [VSuggestedUser]
            where suggestedUsers.count == 5 else {
                XCTFail( "Expected to have some suggested users here." )
                return
        }
        
        XCTAssertEqual(suggestedUsers[0].user.remoteId.integerValue, 3694)
        XCTAssertEqual(suggestedUsers[0].recentSequences.count, 10)
        XCTAssertEqual(suggestedUsers[0].recentSequences[0].remoteId, String(16543))
        
        XCTAssertEqual(suggestedUsers[1].user.remoteId.integerValue, 97)
        XCTAssertEqual(suggestedUsers[1].recentSequences.count, 10)
        XCTAssertEqual(suggestedUsers[1].recentSequences[0].remoteId, String(16393))
        
        XCTAssertEqual(suggestedUsers[2].user.remoteId.integerValue, 708)
        XCTAssertEqual(suggestedUsers[2].recentSequences.count, 9)
        XCTAssertEqual(suggestedUsers[2].recentSequences[0].remoteId, String(12683))
        
        XCTAssertEqual(suggestedUsers[3].user.remoteId.integerValue, 2956)
        XCTAssertEqual(suggestedUsers[3].recentSequences.count, 10)
        XCTAssertEqual(suggestedUsers[3].recentSequences[0].remoteId, String(16891))
        
        XCTAssertEqual(suggestedUsers[4].user.remoteId.integerValue, 1419)
        XCTAssertEqual(suggestedUsers[4].recentSequences.count, 5)
        XCTAssertEqual(suggestedUsers[4].recentSequences[0].remoteId, String(16547))
    }
}
