//
//  ImageAssetTests.swift
//  VictoriousIOSSDK
//
//  Created by Josh Hinman on 10/25/15.
//  Copyright © 2015 Victorious, Inc. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class ImageAssetTests: XCTestCase {

    func testJSONParsing() {
        guard let mockImageAssetDataURL = Bundle(for: type(of: self)).url(forResource: "ImageAsset", withExtension: "json"),
            let mockData = try? Data(contentsOf: mockImageAssetDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        guard let imageAsset = ImageAsset(json: JSON(data: mockData)) else {
            XCTFail("ImageAsset initializer failed")
            return
        }
        XCTAssertEqual(imageAsset.size, CGSize(width: 320, height: 180))
        XCTAssertEqual(imageAsset.url, URL(string: "https://d36dd6wez3mcdh.cloudfront.net/a901cc4e626b33e1fa089aad76fb31ef/320x180.jpg"))
    }
}
