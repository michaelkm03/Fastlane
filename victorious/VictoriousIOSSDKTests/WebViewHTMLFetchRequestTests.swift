//
//  WebViewHTMLFetchRequestTests.swift
//  victorious
//
//  Created by Darvish Kamalia on 6/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import XCTest

@testable import VictoriousIOSSDK

class WebViewHTMLFetchRequestTests: XCTest {
    func testResponseParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("PrivacyPolicy", withExtension: "html"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock html data")
                return
        }
        do {
            let ppRequest = WebViewHTMLFetchRequest(urlPath: mockResponseDataURL.path!)
            let result = try ppRequest.parseResponse(NSURLResponse(), toRequest: ppRequest.urlRequest, responseData: mockData, responseJSON: JSON(data:mockData))
            XCTAssertEqual(result, "<html>testHTML</html>")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
    
    func testTOSParsing() {
        guard let mockResponseDataURL = NSBundle(forClass: self.dynamicType).URLForResource("tos", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockResponseDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        do {
            let tosRequest = TermsOfServiceRequest()
            let htmlString = try tosRequest.parseResponse(NSURLResponse(), toRequest: tosRequest.urlRequest, responseData: mockData, responseJSON: JSON(data:mockData))
            XCTAssertEqual(htmlString, "<html>testHTML</html>")
        } catch {
            XCTFail("Sorry, parseResponse should not throw here")
        }
    }
}