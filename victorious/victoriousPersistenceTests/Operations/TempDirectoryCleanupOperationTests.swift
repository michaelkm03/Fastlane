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
    
    var fileURLs: [NSURL] = []
    private let URL = NSURL(fileURLWithPath: NSTemporaryDirectory())
    private let fileManager = NSFileManager.defaultManager()
    
    override func setUp() {
        super.setUp()
        for a in 1...10 {
            let newURL = URL.URLByAppendingPathComponent("\(a)")
            fileURLs.append(newURL)
            let _ = try? "\(a)".writeToURL(newURL, atomically: true, encoding: NSUTF8StringEncoding)
        }
    }
    
    override func tearDown() {
        for url in fileURLs {
            let _ = try? fileManager.removeItemAtURL(url)
        }
    }
    
    func testClears() {
        weak var expectation = expectationWithDescription("CleanupOperation")
        
        do {
            let count = try fileManager.contentsOfDirectoryAtPath(URL.path!).count
            XCTAssertNotEqual(count, 0)
        } catch {
            XCTFail("Could not read contents of file at path: \(URL.path!)")
        }
        
        TempDirectoryCleanupOperation().queue() { _ in
            let exists = self.fileManager.fileExistsAtPath(self.URL.path!)
            XCTAssertFalse(exists)
            expectation?.fulfill()
        }
        // Waiting for 100 seconds, since we may have a bunch of files to remove.
        waitForExpectationsWithTimeout(100, handler:nil)
    }
}
