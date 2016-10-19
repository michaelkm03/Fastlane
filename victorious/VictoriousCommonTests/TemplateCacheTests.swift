//
//  TemplateCacheTests.swift
//  victorious
//
//  Created by Josh Hinman on 1/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

@testable import VictoriousCommon
import XCTest

class TemplateCacheTests: XCTestCase {

    private let environment = VEnvironment(name: "Mock", baseURL: URL(string: "http://www.example.com")!, appID: 99)
    private let buildNumber = "99"
    private var templateCache: TemplateCache!
    
    override func setUp() {
        super.setUp()
        templateCache = TemplateCache(dataCache: VDataCache(), environment: environment, buildNumber: buildNumber)
    }
    
    func testCache() {
        let mockTemplateData = "Hello World".data(using: String.Encoding.utf8)!
        
        do {
            try templateCache.clearTemplateData()
            try templateCache.cacheTemplateData(mockTemplateData)
        } catch {
            XCTFail()
        }
        
        let result = templateCache.cachedTemplateData()
        XCTAssertEqual(mockTemplateData, result)
    }
    
    func testClearCache() {
        let mockTemplateData = "Hello World".data(using: String.Encoding.utf8)!
        
        do {
            try templateCache.cacheTemplateData(mockTemplateData)
            try templateCache.clearTemplateData()
        } catch {
            XCTFail()
        }
        
        let result = templateCache.cachedTemplateData()
        XCTAssertNil(result)
    }
    
    func testBuildNumberChanged() {
        let mockTemplateData = "Hello World".data(using: String.Encoding.utf8)!
        
        do {
            try templateCache.cacheTemplateData(mockTemplateData)
        } catch {
            XCTFail()
        }
        
        let differentBuildNumberCache = TemplateCache(dataCache: VDataCache(), environment: environment, buildNumber: "1")
        let result = differentBuildNumberCache.cachedTemplateData()
        XCTAssertNil(result)
    }
}
