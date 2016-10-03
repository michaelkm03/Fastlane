//
//  TempDirectoryCleanupOperationTests.swift
//  victorious
//
//  Created by Vincent Ho on 3/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class TempDirectoryCleanupOperationTests: XCTestCase {
    
    var fileURLs: [URL] = []
    fileprivate let url = URL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(kContentCreationDirectory)!
    fileprivate let fileManager = FileManager.default

    override func setUp() {
        super.setUp()
        
        // Cleanup first
        let _ = try? fileManager.removeItemAtURL(url)
        let _ = try? fileManager.createDirectoryAtPath(url.path!, withIntermediateDirectories: true, attributes: nil)
        
        for _ in 1...10 {
            let newURL = url.URLByAppendingPathComponent(UUID().UUIDString)!
            fileURLs.append(newURL)
            fileManager.createFileAtPath(newURL.path!, contents: Data(), attributes: [:])
        }
    }
    
    override func tearDown() {
        for url in fileURLs {
            let _ = try? fileManager.removeItem(at: url)
        }
        let _ = try? fileManager.removeItemAtURL(url)
    }
    
    func testClears() {
        let expectation = self.expectation(description: "Cleanup Expectation")
        
        XCTAssert(fileManager.fileExistsAtPath(url.path!))
        for urls in fileURLs {
            XCTAssert(fileManager.fileExists(atPath: urls.path))
        }
        
        let op = TempDirectoryCleanupOperation()
        op.queue(){ _ in
            XCTAssertFalse(self.fileManager.fileExistsAtPath(self.url.path!))
            for urls in self.fileURLs {
                XCTAssertFalse(self.fileManager.fileExists(atPath: urls.path))
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
