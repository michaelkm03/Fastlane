//
//  APIPathTests.swift
//  victorious
//
//  Created by Jarod Long on 6/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class APIPathTests: XCTestCase {
    func testMacroReplacement() {
        let path = APIPath(templatePath: "http://example.com/%%PLACEHOLDER_1%%/%%PLACEHOLDER_2%%.json", macroReplacements: [
            "%%PLACEHOLDER_1%%": "abc",
            "%%PLACEHOLDER_2%%": "123"
        ])
        
        XCTAssertEqual(path.url.absoluteString, "http://example.com/abc/123.json")
    }
    
    func testQueryParameters() {
        let path = APIPath(templatePath: "http://example.com/my/endpoint", queryParameters: [
            "page": "5",
            "per": "100"
        ])
        
        XCTAssertEqual(path.url.absoluteString, "http://example.com/my/endpoint?per=100&page=5")
    }
    
    func testMacroReplacementWithQueryParameters() {
        let path = APIPath(
            templatePath: "http://example.com/users/%%USER_ID%%/content.json",
            macroReplacements: ["%%USER_ID%%": "5000"],
            queryParameters: [
                "param1": "thing1",
                "param2": "thing2"
            ]
        )
        
        XCTAssertEqual(path.url.absoluteString, "http://example.com/users/5000/content.json?param1=thing1&param2=thing2")
    }
}
