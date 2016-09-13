//
//  TempDirectoryCleanupOperationTests.swift
//  victorious
//
//  Created by Vincent Ho on 3/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class TempDirectoryCleanupOperationTests: BaseFetcherOperationTestCase {
    
    var fileURLs: [NSURL] = []
    private let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(kContentCreationDirectory)!
    private let fileManager = NSFileManager.defaultManager()

    override func setUp() {
        super.setUp()
        
        // Cleanup first
        let _ = try? fileManager.removeItemAtURL(url)
        let _ = try? fileManager.createDirectoryAtPath(url.path!, withIntermediateDirectories: true, attributes: nil)
        
        for _ in 1...10 {
            let newURL = url.URLByAppendingPathComponent(NSUUID().UUIDString)!
            fileURLs.append(newURL)
            fileManager.createFileAtPath(newURL.path!, contents: NSData(), attributes: [:])
        }
    }
    
    override func tearDown() {
        for url in fileURLs {
            let _ = try? fileManager.removeItemAtURL(url)
        }
        let _ = try? fileManager.removeItemAtURL(url)
    }
    
    func testClears() {
        let expectation = expectationWithDescription("Cleanup Expectation")
        
        XCTAssert(fileManager.fileExistsAtPath(url.path!))
        for urls in fileURLs {
            XCTAssert(fileManager.fileExistsAtPath(urls.path!))
        }
        
        let op = TempDirectoryCleanupOperation()
        op.queue(){ _ in
            XCTAssertFalse(self.fileManager.fileExistsAtPath(self.url.path!))
            for urls in self.fileURLs {
                XCTAssertFalse(self.fileManager.fileExistsAtPath(urls.path!))
            }
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(expectationThreshold, handler: nil)
    }
}
