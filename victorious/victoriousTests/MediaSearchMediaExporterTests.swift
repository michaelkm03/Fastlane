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
    
    private let sampleImageURL = Bundle(for: MediaSearchMediaExporterTests.self).url(forResource: "sampleImage", withExtension: fileExtension)!
    
    func testInvalidImageUrl() {
        expectation = self.expectation(description: "MediaSearchMediaExporterTests")
        let mockSearchResult = MockSearchResult(source: MockSource())
        mediaSearchExporter = MediaSearchExporter(mediaSearchResult: mockSearchResult)
        mediaSearchExporter.loadMedia() { previewImage, mediaUrl, error in
            XCTAssertNil(previewImage)
            XCTAssertNil(mediaUrl)
            XCTAssertNotNil(error)
            self.expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDownloadCancelled() {
        expectation = self.expectation(description: "MediaSearchMediaExporterTests")
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
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testDownloadFailed() {
        expectation = self.expectation(description: "MediaSearchMediaExporterTests")
        let string = sampleImageURL.absoluteString
        let urlString = string.substring(to: string.characters.index(before: string.endIndex))
        let newURL = URL(string: urlString)!
        let mockSearchResult = MockSearchResult(source:
            MockSource(sourceMediaURL: newURL, thumbnailImageURL: newURL))
        mediaSearchExporter = MediaSearchExporter(mediaSearchResult: mockSearchResult)
        mediaSearchExporter.loadMedia() { previewImage, mediaUrl, error in
            XCTAssertNil(previewImage)
            XCTAssertNil(mediaUrl)
            XCTAssertNotNil(error)
            self.expectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testValidSourceInformation() {
        expectation = self.expectation(description: "MediaSearchMediaExporterTests")
        let mockSearchResult = MockSearchResult(source:
            MockSource(sourceMediaURL: sampleImageURL, thumbnailImageURL: sampleImageURL))
        mediaSearchExporter = MediaSearchExporter(mediaSearchResult: mockSearchResult)
        
        let path = mediaSearchExporter.downloadUrl!.path
        XCTAssertFalse(FileManager.default.fileExists(atPath: path))
        FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        XCTAssert(FileManager.default.fileExists(atPath: path))
        
        mediaSearchExporter.loadMedia() { previewImage, mediaUrl, error in
            XCTAssertNotNil(previewImage)
            XCTAssertNotNil(mediaUrl)
            XCTAssertNil(error)
            
            // Check to see if the file is deleted
            XCTAssert(FileManager.default.fileExists(atPath: path))
            
            self.expectation.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testDownloadURLWithValidExtension() {
        let mockSearchResult = MockSearchResult(source:
            MockSource(sourceMediaURL: sampleImageURL))
        mediaSearchExporter = MediaSearchExporter(mediaSearchResult: mockSearchResult)
        
        XCTAssert(mediaSearchExporter.downloadUrl!.absoluteString.hasSuffix(fileExtension))
    }
}

struct MockSource {
    let sourceMediaURL: URL
    let thumbnailImageURL: URL
    let remoteID: String
    
    init(sourceMediaURL: URL = URL(string: "foo")!, thumbnailImageURL: URL = URL(string: "foo")!, remoteID: String = "") {
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
    var exportMediaURL: URL?
    var sourceMediaURL: URL? {
        return source.sourceMediaURL
    }
    
    var thumbnailImageURL: URL? {
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
