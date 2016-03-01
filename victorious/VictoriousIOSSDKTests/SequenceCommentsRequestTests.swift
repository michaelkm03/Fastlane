//
//  SequenceCommentsRequestTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/12/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class SequenceCommentsRequestTests: XCTestCase {
    
    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("SequenceCommentsResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let sequenceComments = SequenceCommentsRequest(sequenceID: "1")
            let results = try sequenceComments.parseResponse(NSURLResponse(), toRequest: sequenceComments.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(results.count, 2)
            XCTAssertEqual(results[0].commentID, 28550)
            XCTAssertEqual(results[0].text, "test2")
            XCTAssertEqual(results[1].commentID, 28543)
            XCTAssertEqual(results[1].text, "test")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testRequest() {
        let paginator = StandardPaginator(pageNumber: 1, itemsPerPage: 100)
        let sequenceComments = SequenceCommentsRequest(sequenceID: "99", paginator: paginator)
        XCTAssertEqual(sequenceComments.urlRequest.URL?.absoluteString, "/api/comment/all/99/1/100")
    }
}
