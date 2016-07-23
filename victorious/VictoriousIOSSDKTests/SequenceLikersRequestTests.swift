//
//  SequenceLikersRequestTests.swift
//  victorious
//
//  Created by Josh Hinman on 11/2/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

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
            let sequenceLikers = SequenceLikersRequest(sequenceID: "1")
            let results = try sequenceLikers.parseResponse(NSURLResponse(), toRequest: sequenceLikers.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(results.count, 3)
            XCTAssertEqual(results[0].id, 405130)
            XCTAssertEqual(results[0].displayName, "Sabs")
            XCTAssertEqual(results[1].id, 420812)
            XCTAssertEqual(results[1].displayName, "Eliana")
            XCTAssertEqual(results[2].id, 643629)
            XCTAssertEqual(results[2].displayName, "Lilith_Arianna")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testRequest() {
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 100)
        let sequenceLikers = SequenceLikersRequest(sequenceID: "99", paginator: paginator)
        XCTAssertEqual(sequenceLikers.urlRequest.URL?.absoluteString, "/api/sequence/liked_by_users/99/1/100")
    }
}
