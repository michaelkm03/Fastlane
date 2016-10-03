//
//  NSDictionary+URLEncodedStringTests.swift
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
                           "ampersand=equal": "& ="] as NSDictionary
        
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
                           "dodgers": "doyers" ] as NSDictionary
        
        let urlRequest = NSMutableURLRequest()
        urlRequest.vsdk_addURLEncodedFormPost(mockValues)
        
        XCTAssertEqual(urlRequest.httpMethod, "POST")
        XCTAssertEqual(urlRequest.allHTTPHeaderFields?["Content-Type"], "application/x-www-form-urlencoded; charset=utf-8")
        
        let expectedBody =  mockValues.vsdk_urlEncodedString().dataUsingEncoding(String.Encoding.utf8)
        let actualBody = urlRequest.httpBody
        XCTAssertEqual(expectedBody, actualBody)
    }
    
    func testArrayValueEncodedString() {
        let mockArray = [1, 2] as [Int]
        let mockValues = ["test": "yes", "mockIDs": mockArray.flatMap({ $0 })] as NSDictionary
        
        let urlRequest = NSMutableURLRequest()
        urlRequest.vsdk_addURLEncodedFormPost(mockValues)
        
        XCTAssertEqual(urlRequest.httpMethod, "POST")
        XCTAssertEqual(urlRequest.allHTTPHeaderFields?["Content-Type"], "application/x-www-form-urlencoded; charset=utf-8")
        
        let actualBody = String(data: urlRequest.httpBody!, encoding: String.Encoding.utf8)!
        XCTAssertNotNil(actualBody.range(of: "mockIDs[]=1"))
        XCTAssertNotNil(actualBody.range(of: "mockIDs[]=2"))
        XCTAssertNotNil(actualBody.range(of: "test=yes"))
    }
    
    // Reserved characters according to https://www.ietf.org/rfc/rfc2396.txt
    func testReservedCharacters() {
        let mockValues = ["reserved": ";/?:@&=+,$"] as NSDictionary
        let encoded = mockValues.vsdk_urlEncodedString()
        XCTAssertEqual(encoded, "reserved=%3B%2F%3F%3A%40%26%3D%2B%2C%24")
    }
}
