//
//  VImageAssetTests.swift
//  victorious
//
//  Created by Vincent Ho on 5/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import VictoriousIOSSDK
@testable import victorious

class VImageAssetTests: BasePersistentStoreTestCase {
    func testValid() {
        guard let asset: VImageAsset = createImageAssetFromJSON(
            fileName: "ImageAsset",
            contentType: "video",
            sourceType: "video_assets"
            ) else {
                XCTFail("Failed to create a VImageAsset")
                return
        }

        XCTAssertEqual(asset.height.integerValue, 180)
        XCTAssertEqual(asset.width.integerValue, 320)
        XCTAssertEqual(asset.imageURL, "https://d36dd6wez3mcdh.cloudfront.net/a901cc4e626b33e1fa089aad76fb31ef/320x180.jpg")
    }
    
    private func createImageAssetFromJSON(fileName fileName: String,
                                                          contentType: String,
                                                          sourceType: String) -> VImageAsset? {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource(fileName, withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return nil
        }
        
        guard let contentPreviewAsset = ImageAsset(json: JSON(data: mockData)) else {
            XCTFail("Error reading mock json data")
            return nil
        }
        
        let persistentSequenceModel: VImageAsset = persistentStoreHelper.createImageAsset("")
        persistentSequenceModel.populate(fromSourceModel: contentPreviewAsset)
        return persistentSequenceModel
    }
    
}
