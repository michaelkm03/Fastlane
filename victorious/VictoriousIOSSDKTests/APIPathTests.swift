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
        
        XCTAssertEqual(path.url?.absoluteString, "http://example.com/abc/123.json")
    }
    
    func testQueryParameters() {
        let path = APIPath(templatePath: "http://example.com/my/endpoint", queryParameters: [
            "page": "5",
            "per": "100"
        ])
        
        XCTAssertTrue(path.url?.absoluteString.contains("page=5") ?? false)
        XCTAssertTrue(path.url?.absoluteString.contains("per=100") ?? false)
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
        
        XCTAssertTrue(path.url?.absoluteString.contains("users/5000/content.json") ?? false)
        XCTAssertTrue(path.url?.absoluteString.contains("param1=thing") ?? false)
        XCTAssertTrue(path.url?.absoluteString.contains("param2=thing2") ?? false)
    }
    
    func testEquality() {
        var path1 = APIPath(
            templatePath: "http://apple.com/%%USER_ID%%",
            macroReplacements: ["%%USER_ID%%": "555"],
            queryParameters: ["locale": "en"]
        )
        
        var path2 = path1
        
        XCTAssertEqual(path1, path2)
        
        path1.macroReplacements["%%CONTENT_ID%%"] = "444"
        XCTAssertNotEqual(path1, path2)
        
        path2.macroReplacements["%%CONTENT_ID%%"] = "444"
        XCTAssertEqual(path1, path2)
        
        path2.templatePath += "/content"
        XCTAssertNotEqual(path1, path2)
        
        path1.templatePath += "/content"
        XCTAssertEqual(path1, path2)
        
        path1.queryParameters.removeValue(forKey: "locale")
        XCTAssertNotEqual(path1, path2)
        
        path2.queryParameters.removeValue(forKey: "locale")
        XCTAssertEqual(path1, path2)
    }
}
