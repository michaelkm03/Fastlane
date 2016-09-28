//
//  ContentMediaAssetTests.swift
//  victorious
//
//  Created by Vincent Ho on 5/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

@testable import VictoriousIOSSDK
import XCTest

class ContentMediaAssetTests: XCTestCase {
    
    // MARK: - Video
    
    func testValidVideo() {
        guard let asset: ContentMediaAsset = createMediaAssetFromJSON(
            fileName: "ContentMediaAsset_ValidVideo",
            contentType: "video",
            sourceType: "video_assets"
            ) else {
                XCTFail("Failed to create a ContentMediaAsset")
                return
        }
        
        XCTAssertNil(asset.externalID)
        XCTAssertNil(asset.source)
        XCTAssertEqual(asset.url?.absoluteString, "VALID_URL")
    }
    
    func testInvalidVideoSourceType() {
        let asset: ContentMediaAsset? = createMediaAssetFromJSON(
            fileName: "ContentMediaAsset_ValidVideo",
            contentType: "video",
            sourceType: "invalid_source_type"
        )
        
        XCTAssertNil(asset, "ContentMediaAsset should not have been created with an invalid JSON")
        
    }
    
    func testInvalidVideoNoIdentifier() {
        let asset: ContentMediaAsset? = createMediaAssetFromJSON(
            fileName: "ContentMediaAsset_InvalidVideoNoIdentifier",
            contentType: "video",
            sourceType: "video_assets"
        )
        
        XCTAssertNil(asset, "ContentMediaAsset should not have been created with an invalid JSON")
        
    }
    
    // MARK: - Images
    
    func testValidImage() {
        guard let asset: ContentMediaAsset = createMediaAssetFromJSON(
            fileName: "ContentMediaAsset_ValidImage",
            contentType: "image",
            sourceType: "doesnt_matter"
            ) else {
                XCTFail("Failed to create a ContentMediaAsset")
                return
        }
        
        XCTAssertNil(asset.externalID)
        XCTAssertEqual(asset.url?.absoluteString, "VALID_URL")
    }
    
    func testInvalidImage() {
        let asset: ContentMediaAsset? = createMediaAssetFromJSON(
            fileName: "ContentMediaAsset_InvalidVideoNoIdentifier",
            contentType: "image",
            sourceType: "doesnt_matter"
        )
        
        XCTAssertNil(asset, "ContentMediaAsset should not have been created with an invalid JSON")
        
    }
    
    // MARK: - GIFs
    
    func testValidGIF() {
        guard let asset: ContentMediaAsset = createMediaAssetFromJSON(
            fileName: "ContentMediaAsset_ValidVideo",
            contentType: "gif",
            sourceType: "video_assets"
            ) else {
                XCTFail("Failed to create a ContentMediaAsset")
                return
        }
        
        XCTAssertNil(asset.externalID)
        XCTAssertNil(asset.source)
        XCTAssertEqual(asset.url?.absoluteString, "VALID_URL")
    }
    
    func testInvalidGIFSourceType() {
        let asset: ContentMediaAsset? = createMediaAssetFromJSON(
            fileName: "ContentMediaAsset_ValidVideo",
            contentType: "gif",
            sourceType: "invalid_source_type"
        )
        
        XCTAssertNil(asset, "ContentMediaAsset should not have been created with an invalid JSON")
        
    }
    
    func testInvalidGIFNoIdentifier() {
        let asset: ContentMediaAsset? = createMediaAssetFromJSON(
            fileName: "ContentMediaAsset_InvalidVideoNoIdentifier",
            contentType: "gif",
            sourceType: "video_assets"
        )
        
        XCTAssertNil(asset, "ContentMediaAsset should not have been created with an invalid JSON")
        
    }
    
    // MARK: - Youtube
    
    func testValidYoutube() {
        guard let asset: ContentMediaAsset = createMediaAssetFromJSON(
            fileName: "ContentMediaAsset_ValidYoutube",
            contentType: "video",
            sourceType: "remote_assets"
            ) else {
                XCTFail("Failed to create a ContentMediaAsset")
                return
        }
        
        XCTAssertNil(asset.url)
        XCTAssertEqual(asset.source, "youtube")
        XCTAssertEqual(asset.externalID, "VALID_ID")
    }
    
    func testInvalidVideoNoIdentifierYoutube() {
        let asset: ContentMediaAsset? = createMediaAssetFromJSON(
            fileName: "ContentMediaAsset_InvalidVideoNoIdentifierYoutube",
            contentType: "video",
            sourceType: "remote_assets"
        )
        
        XCTAssertNil(asset, "ContentMediaAsset should not have been created with an invalid JSON")
        
    }
    
    // MARK: - Setup
    
    private func createMediaAssetFromJSON(fileName fileName: String, contentType: String, sourceType: String) -> ContentMediaAsset? {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource(fileName, withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL),
            contentType = ContentType(rawValue: contentType) else {
                XCTFail("Error reading mock json data")
                return nil
        }
        
        return ContentMediaAsset(
            contentType: contentType,
            sourceType: sourceType,
            json: JSON(data: mockData)
        )
    }
    
}
