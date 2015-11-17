//
//  UserInteractionsOnSequenceRequestTests.swift
//  victorious
//
//  Created by Michael Sena on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import VictoriousIOSSDK

class UserInteractionsOnSequenceRequestTests: XCTestCase {

    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("UserInteractionsTest", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        do {
            let userInteractionsRequest = UserInteractionsOnSequenceRequest(sequenceID: 16435, userID:5121)
            let result = try userInteractionsRequest.parseResponse(NSURLResponse(), toRequest: userInteractionsRequest.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertTrue(result)
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testRequest() {
        let userInteractionsRequest = UserInteractionsOnSequenceRequest(sequenceID: 16435, userID:5121)
        XCTAssertEqual(userInteractionsRequest.urlRequest.URL?.absoluteString, "/api/sequence/users_interactions/16435/5121")
    }

}
