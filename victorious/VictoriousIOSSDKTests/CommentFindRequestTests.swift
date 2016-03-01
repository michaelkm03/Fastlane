//
//  CommentFindRequestTests.swift
//  victorious
//
//  Created by Patrick Lynch on 12/2/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class CommentFindRequestTests: XCTestCase {
    
    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("CommentFindResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let request = CommentFindRequest(sequenceID: "1", commentID: 1)
            let result = try request.parseResponse(NSURLResponse(), toRequest: request.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertEqual(result.comments.count, 2)
            XCTAssertEqual(result.comments[0].commentID, 28550)
            XCTAssertEqual(result.comments[0].text, "test2")
            XCTAssertEqual(result.comments[1].commentID, 28543)
            XCTAssertEqual(result.comments[1].text, "test")
            XCTAssertEqual(result.pageNumber, 3)
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testRequest() {
        let request = CommentFindRequest(sequenceID: "99", commentID: 1, itemsPerPage: 100)
        XCTAssertEqual(request.urlRequest.URL?.absoluteString, "/api/comment/find/99/1/100")
    }
}
