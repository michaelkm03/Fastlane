//
//  SequenceRepostersRequestTests.swift
//  victorious
//
//  Created by Patrick Lynch on 11/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON
import VictoriousIOSSDK
import XCTest

class SequenceRepostersRequestTests: XCTestCase {

    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("SequenceRepostersResponse", withExtension: "json"),
              let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        do {
            let sequenceReposters = SequenceRepostersRequest(sequenceID: 1)
            let results = try sequenceReposters.parseResponse(NSURLResponse(), toRequest: sequenceReposters.urlRequest, responseData: mockData, responseJSON: JSON(data: mockData))
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
        let sequenceReposters = SequenceRepostersRequest(sequenceID: 99, pageNumber: 1, itemsPerPage: 100)
        XCTAssertEqual(sequenceReposters.urlRequest.URL?.absoluteString, "/api/repost/all/99/1/100")
    }
}
