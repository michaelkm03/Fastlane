//
//  TextPostAssetTests.swift
//  victorious
//
//  Created by Tian Lan on 2/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import SwiftyJSON
import VictoriousIOSSDK
import XCTest

class TextPostAssetTests: XCTestCase {
    
    func testJSONParsing() {
        guard let mockTextPostAssetDataURL = NSBundle(forClass: self.dynamicType).URLForResource("TextPostAsset", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockTextPostAssetDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        guard let textPostAsset = TextPostAsset(json: JSON(data: mockData)) else {
            XCTFail("TextPostAsset initializer failed")
            return
        }
        
        XCTAssertEqual(textPostAsset.type, AssetType.Text)
        XCTAssertEqual(textPostAsset.data, "#funny there we go!")
        XCTAssertEqual(textPostAsset.backgroundColor, "3c81c3")
        XCTAssertEqual(textPostAsset.backgroundImageURL, "http://media-dev-public.s3-website-us-west-1.amazonaws.com/92a67fc299de58cbf7fb98ff065181ca/640x640.jpg")
    }
}
