//
//  DataTests.swift
//  victorious
//
//  Created by Sebastian Nystorm on 13/10/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest

@testable import victorious

class DataTests: XCTestCase {
    
    func testImageTypes() {
        do {
            let testBundle = Bundle(for: DataTests.self)

            // JPEG
            let jpgImagePath = testBundle.path(forResource: "sampleImage", ofType: "jpg")!
            let jpgData = try Data(contentsOf: URL(fileURLWithPath: jpgImagePath))

            let jpgImageType = jpgData.imageType()
            XCTAssertTrue(jpgImageType?.contentType == "image/jpeg", "Expected content type to be same.")
            XCTAssertTrue(jpgImageType?.fileExtension == "jpeg", "Expected file extensions to be same.")

            // PNG
            let pngImagePath = testBundle.path(forResource: "sampleImage", ofType: "png")!
            let pngData = try Data(contentsOf: URL(fileURLWithPath: pngImagePath))

            let pngImageType = pngData.imageType()
            XCTAssertTrue(pngImageType?.contentType == "image/png", "Expected content type to be same.")
            XCTAssertTrue(pngImageType?.fileExtension == "png", "Expected file extensions to be same.")

            // GIF
            let gifImagePath = testBundle.path(forResource: "sampleImage", ofType: "gif")!
            let gifData = try Data(contentsOf: URL(fileURLWithPath: gifImagePath))

            let gifImageType = gifData.imageType()
            XCTAssertTrue(gifImageType?.contentType == "image/gif", "Expected content type to be same.")
            XCTAssertTrue(gifImageType?.fileExtension == "gif", "Expected file extensions to be same.")

            // TIFF
            let tiffImagePath = testBundle.path(forResource: "sampleImage", ofType: "tiff")!
            let tiffData = try Data(contentsOf: URL(fileURLWithPath: tiffImagePath))

            let tiffImageType = tiffData.imageType()
            XCTAssertTrue(tiffImageType?.contentType == "image/tiff", "Expected content type to be same.")
            XCTAssertTrue(tiffImageType?.fileExtension == "tiff", "Expected file extensions to be same.")

        } catch {
            XCTFail("Failed to read test data from disk with error -> \(error)")
        }
    }
}
