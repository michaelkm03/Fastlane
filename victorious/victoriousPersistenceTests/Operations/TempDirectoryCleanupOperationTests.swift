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
    private let URL = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(kContentCreationDirectory)
    private let fileManager = NSFileManager.defaultManager()
    
    override func setUp() {
        super.setUp()
        
        // Cleanup first
        let _ = try? fileManager.removeItemAtURL(URL)
        let _ = try? fileManager.createDirectoryAtPath(URL.path!, withIntermediateDirectories: true, attributes: nil)
        
        for _ in 1...10 {
            let newURL = URL.URLByAppendingPathComponent(NSUUID().UUIDString)
            fileURLs.append(newURL)
            fileManager.createFileAtPath(newURL.path!, contents: NSData(), attributes: [:])
        }
    }
    
    override func tearDown() {
        for url in fileURLs {
            let _ = try? fileManager.removeItemAtURL(url)
        }
        let _ = try? fileManager.removeItemAtURL(URL)
    }
    
    func testClears() {
        XCTAssert(fileManager.fileExistsAtPath(URL.path!))
        for urls in fileURLs {
            XCTAssert(fileManager.fileExistsAtPath(urls.path!))
        }
        TempDirectoryCleanupOperation().start()
        XCTAssertFalse(self.fileManager.fileExistsAtPath(self.URL.path!))
        for urls in self.fileURLs {
            XCTAssertFalse(self.fileManager.fileExistsAtPath(urls.path!))
        }
    }
}
