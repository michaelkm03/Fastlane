//
//  VContentPreviewAssetTests.swift
//  victorious
//
//  Created by Vincent Ho on 5/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import VictoriousIOSSDK
@testable import victorious

class VContentPreviewAssetTests: BasePersistentStoreTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func testValid() {
        guard let asset: VContentPreviewAsset = createContentMediaAssetFromJSON(
            fileName: "ContentPreviewAsset",
            contentType: "video",
            sourceType: "video_assets"
            ) else {
                XCTFail("Failed to create a VContentPreviewAsset")
                return
        }
        
        XCTAssertEqual(asset.height?.integerValue, 100)
        XCTAssertEqual(asset.width?.integerValue, 200)
        XCTAssertEqual(asset.type, "image")
        XCTAssertEqual(asset.imageURL, "VALID_URL")
    }
    
    private func createContentMediaAssetFromJSON(fileName fileName: String,
                                                          contentType: String,
                                                          sourceType: String) -> VContentPreviewAsset? {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource(fileName, withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return nil
        }
        
        guard let contentPreviewAsset = ImageAsset(json: JSON(data: mockData)) else {
            XCTFail("Error reading mock json data")
            return nil
        }
        
        let persistentSequenceModel: VContentPreviewAsset = persistentStoreHelper.createContentPreviewAsset("")
        persistentSequenceModel.populate(fromSourceModel: contentPreviewAsset)
        return persistentSequenceModel
    }
    
}
