//
//  MediaUploadCreateRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 1/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class MediaUploadCreateRequestTests: XCTestCase {
    
    let mockURLString = "http://www.google.com/api/mediaupload/create"

    func testRequest() {
        let request = MediaUploadCreateRequest(apiPath: APIPath(templatePath: mockURLString))
        
        XCTAssertEqual(request?.urlRequest.URL?.absoluteString, "\(mockURLString)")
    }
    
    func testResponse() {
        let request = MediaUploadCreateRequest(apiPath: APIPath(templatePath: mockURLString))!
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
