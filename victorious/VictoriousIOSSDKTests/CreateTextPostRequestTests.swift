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
    
    let mockBaseURLString = "http://www.google.com"
    
    func testRequestWithValidBackgroundColor() {
        let mockParameters = TextPostParameters(content: "mockTextPostContent", backgroundImageURL: nil, backgroundColor: UIColor.blueColor())
        guard let request = CreateTextPostRequest(parameters: mockParameters, baseURL: NSURL(string: mockBaseURLString)!) else {
            XCTFail("Request Creation should not fail here")
            return
        }
        let urlRequest = request.urlRequest
        
        XCTAssertEqual(urlRequest.URL?.absoluteString, "\(mockBaseURLString)/api/text/create")
    }
    
    func testRequestWithValidBackgroundImageURL() {
        let mockParameters = TextPostParameters(content: "mockTextPostContent", backgroundImageURL: NSURL(string: "file://someurl/to/image.png")!, backgroundColor: nil)
        guard let request = CreateTextPostRequest(parameters: mockParameters, baseURL: NSURL(string: mockBaseURLString)!) else {
            XCTFail("Request Creation should not fail here")
            return
        }
        let urlRequest = request.urlRequest
        
        XCTAssertEqual(urlRequest.URL?.absoluteString, "\(mockBaseURLString)/api/text/create")
    }
    
    func testREquestWithInvalidParameters() {
        let mockParameters = TextPostParameters(content: "mockTextPostContent", backgroundImageURL: nil, backgroundColor: nil)
        let request = CreateTextPostRequest(parameters: mockParameters, baseURL: NSURL(string: mockBaseURLString)!)
        XCTAssertNil(request)
    }
    
    func testParseResponse() {
        let mockParameters = TextPostParameters(content: "mockTextPostContent", backgroundImageURL: nil, backgroundColor: UIColor.blueColor())
        guard let request = CreateTextPostRequest(parameters: mockParameters, baseURL: NSURL(string: mockBaseURLString)!) else {
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
