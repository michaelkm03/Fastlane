//
//  VContentMediaAssetTests.swift
//  victorious
//
//  Created by Vincent Ho on 5/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import VictoriousIOSSDK
@testable import victorious

class VContentMediaAssetTests: BasePersistentStoreTestCase {
    func testValidVideo() {
        guard let asset: VContentMediaAsset = createContentMediaAssetFromJSON(
            fileName: "ContentMediaAsset_ValidVideo",
            contentType: "video",
            sourceType: "video_assets"
        ) else {
            XCTFail("Failed to create a VContentMediaAsset")
            return
        }
        
        XCTAssertNil(asset.v_externalID)
        XCTAssertNil(asset.v_source)
        XCTAssertEqual(asset.v_remoteSource, "VALID_URL")
        XCTAssertEqual(asset.v_uniqueID, asset.v_remoteSource)
    }
    
    func testValidYoutube() {
        guard let asset: VContentMediaAsset = createContentMediaAssetFromJSON(
            fileName: "ContentMediaAsset_ValidYoutube",
            contentType: "video",
            sourceType: "remote_assets"
        ) else {
            XCTFail("Failed to create a VContentMediaAsset")
            return
        }
        
        XCTAssertNil(asset.v_remoteSource)
        XCTAssertEqual(asset.v_source, "youtube")
        XCTAssertEqual(asset.v_externalID, "VALID_ID")
        XCTAssertEqual(asset.v_uniqueID, asset.v_externalID)
    }
    
    func testValidGIF() {
        guard let asset: VContentMediaAsset = createContentMediaAssetFromJSON(
            fileName: "ContentMediaAsset_ValidVideo",
            contentType: "gif",
            sourceType: "video_assets"
        ) else {
            XCTFail("Failed to create a VContentMediaAsset")
            return
        }
        
        XCTAssertNil(asset.v_externalID)
        XCTAssertNil(asset.v_source)
        XCTAssertEqual(asset.v_remoteSource, "VALID_URL")
        XCTAssertEqual(asset.v_uniqueID, asset.v_remoteSource)
    }
    
    func testValidImage() {
        guard let asset: VContentMediaAsset = createContentMediaAssetFromJSON(
            fileName: "ContentMediaAsset_ValidImage",
            contentType: "image",
            sourceType: "doesnt_matter"
        ) else {
            XCTFail("Failed to create a VContentMediaAsset")
            return
        }
        
        XCTAssertNil(asset.v_externalID)
        XCTAssertEqual(asset.v_remoteSource, "VALID_URL")
        XCTAssertEqual(asset.v_uniqueID, asset.v_remoteSource)
    }
    
    private func createContentMediaAssetFromJSON(fileName fileName: String, contentType: String, sourceType: String) -> VContentMediaAsset? {
        guard
            let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource(fileName, withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL)
        else {
            XCTFail("Error reading mock json data")
            return nil
        }
        
        guard
            let contentType = ContentType(rawValue: contentType),
            let contentMediaAsset = ContentMediaAsset(contentType: contentType, sourceType: sourceType, json: JSON(data: mockData))
        else {
            XCTFail("Error reading mock json data")
            return nil
        }
        
        let persistentSequenceModel: VContentMediaAsset = persistentStoreHelper.createContentMediaAsset("1")
        persistentSequenceModel.populate(fromSourceModel: contentMediaAsset)
        return persistentSequenceModel
    }
    
}
