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
        var results: SuggestedUsersRequest.ResultType = []
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("SuggestedUsersResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let suggestedUsersRequest = SuggestedUsersRequest()
            results = try suggestedUsersRequest.parseResponse(NSURLResponse(), toRequest: suggestedUsersRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }

        let operation = SuggestedUsersOperation()

        operation.onComplete(results){ }
        let suggestedUsers = operation.suggestedUsers
        XCTAssertEqual(suggestedUsers.count, 5)
        
        XCTAssertEqual(suggestedUsers[0].user.remoteId, 3694)
        XCTAssertEqual(suggestedUsers[0].recentSequences.count, 10)
        XCTAssertEqual(suggestedUsers[0].recentSequences[0].remoteId, String(16543))
        
        XCTAssertEqual(suggestedUsers[1].user.remoteId, 97)
        XCTAssertEqual(suggestedUsers[1].recentSequences.count, 10)
        XCTAssertEqual(suggestedUsers[1].recentSequences[0].remoteId, String(16393))
        
        XCTAssertEqual(suggestedUsers[2].user.remoteId, 708)
        XCTAssertEqual(suggestedUsers[2].recentSequences.count, 9)
        XCTAssertEqual(suggestedUsers[2].recentSequences[0].remoteId, String(12683))
        
        XCTAssertEqual(suggestedUsers[3].user.remoteId, 2956)
        XCTAssertEqual(suggestedUsers[3].recentSequences.count, 10)
        XCTAssertEqual(suggestedUsers[3].recentSequences[0].remoteId, String(16891))
        
        XCTAssertEqual(suggestedUsers[4].user.remoteId, 1419)
        XCTAssertEqual(suggestedUsers[4].recentSequences.count, 5)
        XCTAssertEqual(suggestedUsers[4].recentSequences[0].remoteId, String(16547))
    }
}
