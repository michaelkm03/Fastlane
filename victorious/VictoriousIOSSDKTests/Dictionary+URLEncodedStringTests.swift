//
//  Dictionary+URLEncodedStringTests.swift
//  VictoriousIOSSDK
//
//  Created by Josh Hinman on 10/25/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import Foundation
import VictoriousIOSSDK
import XCTest

class URLEncodedStringTests: XCTestCase {
    
    func testURLEncodedString() {
        let mockValues = [ "foo": "bar",
                           "strawberry": "🍓",
                           "ampersand=equal": "& ="]
        
        let result = mockValues.vsdk_urlEncodedString()
        
        XCTAssertNotNil(result.rangeOfString("foo=bar"))
        XCTAssertNotNil(result.rangeOfString("strawberry=%F0%9F%8D%93"))
        XCTAssertNotNil(result.rangeOfString("ampersand%3Dequal=%26%20%3D"))
        XCTAssertEqual(result.characters.count, 59)
        
        let regex = try! NSRegularExpression(pattern: "^[^=&]+=[^=&]+&[^=&]+=[^=&]+&[^=&]+=[^=&]+$", options: [])
        XCTAssertEqual(regex.matchesInString(result, options: [], range: NSMakeRange(0, result.characters.count)).count, 1)
    }
    
    func testMutableURLRequestAddURLEncodedFormPost() {
        let mockValues = [ "foo": "bar",
                           "dodgers": "doyers" ]
        
        let urlRequest = NSMutableURLRequest()
        urlRequest.vsdk_addURLEncodedFormPost(mockValues)
        
        XCTAssertEqual(urlRequest.HTTPMethod, "POST")
        XCTAssertEqual(urlRequest.allHTTPHeaderFields?["Content-Type"], "application/x-www-form-urlencoded; charset=utf-8")
        
        let expectedBody =  mockValues.vsdk_urlEncodedString().dataUsingEncoding(NSUTF8StringEncoding)
        let actualBody = urlRequest.HTTPBody
        XCTAssertEqual(expectedBody, actualBody)
    }
}