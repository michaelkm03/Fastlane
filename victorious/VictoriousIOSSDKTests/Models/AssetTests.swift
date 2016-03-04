//
//  AssetTests.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class AssetTests: XCTestCase {
    
    func testJSONParsing() {
        guard let mockAssetDataURL = NSBundle(forClass: self.dynamicType).URLForResource("Asset", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockAssetDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        guard let asset = Asset(json: JSON(data: mockData)) else {
            XCTFail("Asset initializer failed")
            return
        }
        
        XCTAssertEqual(asset.type, AssetType.Path)
        XCTAssertEqual(asset.streamAutoplay, false)
        XCTAssertEqual(asset.speed, 1)
        XCTAssertEqual(asset.remoteSource, "app")
        XCTAssertEqual(asset.remotePlayback, false)
        XCTAssertEqual(asset.remoteContentID, "content_id")
        XCTAssertEqual(asset.playerControlsDisabled, false)
        XCTAssertEqual(asset.mimeType, "video/mp4")
        XCTAssertEqual(asset.loop, false)
        XCTAssertEqual(asset.duration, 6)
        XCTAssertEqual(asset.data, "http://media-dev-public.s3-website-us-west-1.amazonaws.com/69921215db55c8a7d744a992398a86d8/480/video.mp4")
        XCTAssertEqual(asset.backgroundImageUrl, "http://media-dev-public.s3-website-us-west-1.amazonaws.com/69921215db55c8a7d744a992398a86d8/640x360.jpg")
        XCTAssertEqual(asset.backgroundColor, "ff7c00")
        XCTAssertEqual(asset.audioMuted, false)
    }
}
