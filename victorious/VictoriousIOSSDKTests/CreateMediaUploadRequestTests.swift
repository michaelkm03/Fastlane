//
//  CreateMediaUploadRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 1/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
import SwiftyJSON

class CreateMediaUploadRequestTests: XCTestCase {
    
    let mockBaseURLString = "http://www.google.com"

    func testRequest() {
        let request = CreateMediaUploadRequest(baseURL: NSURL(string: mockBaseURLString)!)
        
        XCTAssertEqual(request.urlRequest.URL?.absoluteString, "\(mockBaseURLString)/api/mediaupload/create")
    }
    
    func testResponse() {
        let request = CreateMediaUploadRequest(baseURL: NSURL(string: mockBaseURLString)!)
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
