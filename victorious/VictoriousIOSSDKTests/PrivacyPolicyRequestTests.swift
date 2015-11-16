//
//  PrivacyPolicyRequestTests.swift
//  victorious
//
//  Created by Michael Sena on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON
import XCTest

@testable import VictoriousIOSSDK

class PrivacyPolicyRequestTests: XCTestCase {

    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("PrivacyPolicy", withExtension: "html"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock html data")
                return
        }
        do {
            let ppRequest = PrivacyPolicyRequest()
            let result = try ppRequest.parseHTML(NSURLResponse(), toRequest:ppRequest.urlRequest, responseData: mockData)
            XCTAssertEqual(result, "<html>testHTML</html>")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testRequest() {
        let tosRequest = PrivacyPolicyRequest()
        XCTAssertEqual(tosRequest.urlRequest.URL?.absoluteString, "/api/static/privacy")
    }
    
}
