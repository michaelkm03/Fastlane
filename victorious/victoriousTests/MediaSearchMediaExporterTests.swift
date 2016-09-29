//
//  MediaSearchMediaExporterTests.swift
//  victorious
//
//  Created by Vincent Ho on 3/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

let fileExtension: String = "jpg"

class MediaSearchMediaExporterTests: XCTestCase {
    
    var mediaSearchExporter: MediaSearchExporter!
    var expectation: XCTestExpectation!
    
    private let sampleImageURL = NSBundle(forClass: MediaSearchMediaExporterTests.self).URLForResource("sampleImage", withExtension: fileExtension)!
    
    func testInvalidImageUrl() {
        expectation = expectationWithDescription("MediaSearchMediaExporterTests")
        let mockSearchResult = MockSearchResult(source: MockSource())
        mediaSearchExporter = MediaSearchExporter(mediaSearchResult: mockSearchResult)
        mediaSearchExporter.loadMedia() { previewImage, mediaUrl, error in
            XCTAssertNil(previewImage)
            XCTAssertNil(mediaUrl)
            XCTAssertNotNil(error)
            self.expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testDownloadCancelled() {
        expectation = expectationWithDescription("MediaSearchMediaExporterTests")
        let mockSearchResult = MockSearchResult(source:
            MockSource(sourceMediaURL: sampleImageURL, thumbnailImageURL: sampleImageURL))
        mediaSearchExporter = MediaSearchExporter(mediaSearchResult: mockSearchResult)
        mediaSearchExporter.loadMedia() { previewImage, mediaUrl, error in
            XCTAssert(self.mediaSearchExporter.cancelled)
            XCTAssertNil(previewImage)
            XCTAssertNil(mediaUrl)
            XCTAssertNotNil(error)
            self.expectation.fulfill()
        }
        mediaSearchExporter.cancelDownload()
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testDownloadFailed() {
        expectation = expectationWithDescription("MediaSearchMediaExporterTests")
        let string = sampleImageURL.absoluteString!
        let urlString = string.substringToIndex(string.endIndex.predecessor())
        let newURL = NSURL(string: urlString)!
        let mockSearchResult = MockSearchResult(source:
            MockSource(sourceMediaURL: newURL, thumbnailImageURL: newURL))
        mediaSearchExporter = MediaSearchExporter(mediaSearchResult: mockSearchResult)
        mediaSearchExporter.loadMedia() { previewImage, mediaUrl, error in
            XCTAssertNil(previewImage)
            XCTAssertNil(mediaUrl)
            XCTAssertNotNil(error)
            self.expectation.fulfill()
        }
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    func testValidSourceInformation() {
        expectation = expectationWithDescription("MediaSearchMediaExporterTests")
        let mockSearchResult = MockSearchResult(source:
            MockSource(sourceMediaURL: sampleImageURL, thumbnailImageURL: sampleImageURL))
        mediaSearchExporter = MediaSearchExporter(mediaSearchResult: mockSearchResult)
        
        let path = mediaSearchExporter.downloadUrl!.path!
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
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testDownloadURLWithValidExtension() {
        let mockSearchResult = MockSearchResult(source:
            MockSource(sourceMediaURL: sampleImageURL))
        mediaSearchExporter = MediaSearchExporter(mediaSearchResult: mockSearchResult)
        
        XCTAssert(mediaSearchExporter.downloadUrl!.absoluteString!.hasSuffix(fileExtension))
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
    
    var isVIP: Bool {
        return false
    }
}
