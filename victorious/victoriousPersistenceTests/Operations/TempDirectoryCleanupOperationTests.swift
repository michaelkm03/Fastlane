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
    private let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(kContentCreationDirectory)
    private let fileManager = FileManager.default

    override func setUp() {
        super.setUp()
        
        // Cleanup first
        let _ = try? fileManager.removeItem(at: url)
        let _ = try? fileManager.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
        
        for _ in 1...10 {
            let newURL = url.appendingPathComponent(UUID().uuidString)
            fileURLs.append(newURL)
            fileManager.createFile(atPath: newURL.path, contents: Data(), attributes: [:])
        }
    }
    
    override func tearDown() {
        for url in fileURLs {
            let _ = try? fileManager.removeItem(at: url)
        }
        let _ = try? fileManager.removeItem(at: url)
    }
    
    func testClears() {
        let expectation = self.expectation(description: "Cleanup Expectation")
        
        XCTAssert(fileManager.fileExists(atPath: url.path))
        for urls in fileURLs {
            XCTAssert(fileManager.fileExists(atPath: urls.path))
        }
        
        let op = TempDirectoryCleanupOperation()
        op.queue(){ _ in
            XCTAssertFalse(self.fileManager.fileExists(atPath: self.url.path))
            for urls in self.fileURLs {
                XCTAssertFalse(self.fileManager.fileExists(atPath: urls.path))
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
