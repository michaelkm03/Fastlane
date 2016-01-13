//
//  CreateTextPostRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 1/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
import SwiftyJSON

class CreateTextPostRequestTests: XCTestCase {
    
    func testRequest() {
        let mockParameters = TextPostParameters(content: "mockTextPostContent", background: .BackgoundColor(UIColor.blueColor()))
        guard let request = CreateTextPostRequest(parameters: mockParameters) else {
            XCTFail("Request Creation should not fail here")
            return
        }
        let urlRequest = request.urlRequest
        
        XCTAssertEqual(urlRequest.URL?.absoluteString, "/api/text/create")
    }
    
    func testParseResponse() {
        let mockParameters = TextPostParameters(content: "mockTextPostContent", background: .BackgoundColor(UIColor.blueColor()))
        guard let request = CreateTextPostRequest(parameters: mockParameters) else {
            XCTFail("Request Creation should not fail here")
            return
        }
        
        let mockSequenceID = "mockSequenceID"
        let mockJSON = JSON( [ "payload": ["sequence_id": mockSequenceID] ] )
        
        do {
            let results = try request.parseResponse(NSURLResponse(), toRequest: request.urlRequest, responseData: NSData(), responseJSON: mockJSON)
            
            XCTAssertEqual(results, mockSequenceID)
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
}
