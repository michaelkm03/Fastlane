//
//  StreamTests.swift
//  victorious
//
//  Created by Patrick Lynch on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON
import VictoriousIOSSDK
import XCTest

class StreamTests: XCTestCase {
    
    func testJSONParsing() {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("Stream", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        guard let stream = Stream(json: JSON(data: mockData)) else {
            XCTFail("User initializer failed")
            return
        }
        
        XCTAssertEqual(stream.remoteID, "")
        XCTAssertEqual(stream.remoteID, "")
        XCTAssertEqual(stream.type, "")
        XCTAssertEqual(stream.subtype, "")
        XCTAssertEqual(stream.name, "")
        XCTAssertEqual(stream.title, "" )
        XCTAssertEqual(stream.postCount, "" )
        XCTAssertEqual(stream.streamUrl, "" )
        XCTAssertEqual(stream.items, "" )
        
        XCTAssertEqual(stream.previewImagesObject, "")
        XCTAssertEqual(stream.previewTextPostAsset, "")
        XCTAssertEqual(stream.streamContentType, "" )
        XCTAssertEqual(stream.itemType, "" )
        XCTAssertEqual(stream.itemSubType, "" )
        XCTAssertEqual(stream.previewImageAssets, [])
        XCTAssertEqual(stream.streams, [])
    }
}
