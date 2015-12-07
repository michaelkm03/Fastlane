//
//  SequenceLikersRequestTests.swift
//  victorious
//
//  Created by Josh Hinman on 11/2/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON
import VictoriousIOSSDK
import XCTest

class SequenceLikersRequestTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("SequenceLikersResponse", withExtension: "json"),
              let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let sequenceLikers = SequenceLikersRequest(sequenceID: 1)
            let results = try sequenceLikers.parseResponse(NSURLResponse(), toRequest: sequenceLikers.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(results.count, 3)
            XCTAssertEqual(results[0].userID, 405130)
            XCTAssertEqual(results[0].name, "Sabs")
            XCTAssertEqual(results[1].userID, 420812)
            XCTAssertEqual(results[1].name, "Eliana")
            XCTAssertEqual(results[2].userID, 643629)
            XCTAssertEqual(results[2].name, "Lilith_Arianna")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testRequest() {
        let sequenceLikers = SequenceLikersRequest(sequenceID: 99, pageNumber: 1, itemsPerPage: 100)
        XCTAssertEqual(sequenceLikers.urlRequest.URL?.absoluteString, "/api/sequence/liked_by_users/99/1/100")
    }
}
