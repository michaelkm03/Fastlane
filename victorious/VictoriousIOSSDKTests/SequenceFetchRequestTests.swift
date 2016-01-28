//
//  SequenceFetchRequestTests.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import VictoriousIOSSDK

class SequenceFetchRequestTests: XCTestCase {
    
    func testConfiguredRequest() {
        let id: String = "3694"
        let request =  SequenceFetchRequest(sequenceID: id )
        XCTAssertEqual( request.urlRequest.URL, NSURL(string: "/api/sequence/fetch/\(id)") )
        XCTAssertEqual( request.urlRequest.HTTPMethod, "GET" )
    }
    
    func testParseResponse() {
        
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("SequenceFetchResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        let request =  SequenceFetchRequest(sequenceID: "17143")
        do {
            try request.parseResponse(NSURLResponse(), toRequest: NSURLRequest(), responseData: mockData, responseJSON: JSON(data: mockData))
        } catch {
            XCTFail("parseResponse is not supposed to throw")
            return
        }
    }
}
