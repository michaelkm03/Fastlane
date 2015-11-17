//
//  TermsOfServiceRequestTests.swift
//  victorious
//
//  Created by Michael Sena on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON
import XCTest

@testable import VictoriousIOSSDK

class TermsOfServiceRequestTests: XCTestCase {
    
    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("tos", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        do {
            let tosRequest = TermsOfServiceRequest()
            let htmlString = try tosRequest.parseResponse(NSURLResponse(), toRequest:tosRequest.urlRequest, responseData: mockData, responseJSON: JSON(data:mockData))
            XCTAssertEqual(htmlString, "<html>testHTML</html>")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testRequest() {
        let tosRequest = TermsOfServiceRequest()
        XCTAssertEqual(tosRequest.urlRequest.URL?.absoluteString, "/api/tos")
    }
    
}