//
//  MediaSearchMediaExporterTests.swift
//  victorious
//
//  Created by Vincent Ho on 3/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class MediaSearchMediaExporterTests: XCTestCase {
    
    var mediaSearchExporter: MediaSearchExporter!
    var expectation: XCTestExpectation!
    private let sampleImageURL = NSBundle(forClass: AchievementTests.self).URLForResource("sampleImage", withExtension: "jpg")!
    
    override func setUp() {
        super.setUp()
        expectation = expectationWithDescription("MediaSearchMediaExporterTests")
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testInvalidImageUrl() {
        let mockSearchResult = MockSearchResult(source: MockSource())
        mediaSearchExporter = MediaSearchExporter(mediaSearchResult: mockSearchResult)
        mediaSearchExporter.loadMedia() { previewImage, mediaUrl, error in
            XCTAssertNil(previewImage)
            XCTAssertNil(mediaUrl)
            XCTAssertNotNil(error)
            self.expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1) { error in
        }
    }
    
    func testDownloadCancelled() {
        let mockSearchResult = MockSearchResult(source:
            MockSource(sourceMediaURL: sampleImageURL, thumbnailImageURL: sampleImageURL))
        mediaSearchExporter = MediaSearchExporter(mediaSearchResult: mockSearchResult)
        mediaSearchExporter.loadMedia() { previewImage, mediaUrl, error in
            XCTAssert(self.mediaSearchExporter.cancelled)
            XCTAssertNil(previewImage)
            XCTAssertNil(mediaUrl)
            XCTAssertNotNil(error)
        }
        mediaSearchExporter.cancelDownload()
        dispatch_after(1, {
            self.expectation.fulfill()
        })
        waitForExpectationsWithTimeout(2) { error in
        }
    }
    
    func testDownloadFailed() {
        let newURL = NSURL(string: "\(sampleImageURL.absoluteString)...\(sampleImageURL.absoluteString)")!
        let mockSearchResult = MockSearchResult(source:
            MockSource(sourceMediaURL: newURL, thumbnailImageURL: newURL))
        mediaSearchExporter = MediaSearchExporter(mediaSearchResult: mockSearchResult)
        mediaSearchExporter.loadMedia() { previewImage, mediaUrl, error in
            XCTAssertNil(previewImage)
            XCTAssertNil(mediaUrl)
            XCTAssertNotNil(error)
        }
        dispatch_after(1, {
            self.expectation.fulfill()
        })
        waitForExpectationsWithTimeout(2) { error in
        }
    }
    
    func testValidSourceInformation() {
        
        let mockSearchResult = MockSearchResult(source:
            MockSource(sourceMediaURL: sampleImageURL, thumbnailImageURL: sampleImageURL))
        mediaSearchExporter = MediaSearchExporter(mediaSearchResult: mockSearchResult)
        
        let path = mediaSearchExporter.downloadURL.path!
        XCTAssertFalse(NSFileManager.defaultManager().fileExistsAtPath(path))
        NSFileManager.defaultManager().createFileAtPath(path, contents: nil, attributes: nil)
        XCTAssert(NSFileManager.defaultManager().fileExistsAtPath(path))
        
        mediaSearchExporter.loadMedia() { previewImage, mediaUrl, error in
            XCTAssertNotNil(previewImage)
            XCTAssertNotNil(mediaUrl)
            XCTAssertNil(error)
            
            // Check to see if the file is deleted
            XCTAssert(NSFileManager.defaultManager().fileExistsAtPath(path))
            
            self.expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1) { error in
        }
    }
    
}

struct MockSource {
    let sourceMediaURL: NSURL
    let thumbnailImageURL: NSURL
    let remoteID: String
    
    init(sourceMediaURL: NSURL = NSURL(), thumbnailImageURL: NSURL = NSURL(), remoteID: String = "") {
        self.sourceMediaURL = sourceMediaURL
        self.thumbnailImageURL = thumbnailImageURL
        self.remoteID = remoteID
    }
}

@objc class MockSearchResult: NSObject, MediaSearchResult {
    let source: MockSource
    
    init( source: MockSource ) {
        self.source = source
    }
    
    var exportPreviewImage: UIImage?
    var exportMediaURL: NSURL?
    var sourceMediaURL: NSURL? {
        return source.sourceMediaURL
    }
    
    var thumbnailImageURL: NSURL? {
        return source.thumbnailImageURL
    }
    
    var aspectRatio: CGFloat {
        return 1.0
    }
    
    var assetSize: CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    var remoteID: String? {
        return source.remoteID
    }
}
