//
//  ShelfTests.swift
//  victorious
//
//  Created by Tian Lan on 1/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class ShelfTests: XCTestCase {
    
    func testValid() {
        guard let url = NSBundle(forClass: self.dynamicType).URLForResource("ExploreMarqueeShelfResponse", withExtension: "json" ),
            let mockData = NSData(contentsOfURL: url) else {
                XCTFail("Error reading mock json data" )
                return
        }
        guard let shelf = Shelf(json: JSON(data: mockData)) else {
            XCTFail("Shelf initializer failed" )
            return
        }
        
        XCTAssertEqual(shelf.streamID, "16472")
        XCTAssertEqual(shelf.type, .Shelf )
        XCTAssertEqual(shelf.subtype, .Marquee)
        XCTAssertEqual(shelf.name, "Explore Stream")
        XCTAssertEqual(shelf.title, "Marquee")
        XCTAssertEqual(shelf.postCount, 14)
        XCTAssertEqual(shelf.streamUrl, "http://dev.getvictorious.com/api/sequence/detail_list_by_stream_with_marquee/16472/0/%%PAGE_NUM%%/%%ITEMS_PER_PAGE%%")
        
        XCTAssertEqual(shelf.items?.count, 12)
        XCTAssertEqual(shelf.items?.filter { $0 is Sequence }.count, 0)
        XCTAssertEqual(shelf.items?.filter { $0 is Stream }.count, 12)
        
        XCTAssertNil(shelf.previewImagesObject)
        XCTAssertNil(shelf.previewAsset)
        XCTAssertNil(shelf.previewImageAssets)
    }
    
    func testDefaults() {
        guard let url = NSBundle(forClass: self.dynamicType).URLForResource("SimpleStream", withExtension: "json" ),
            let mockData = NSData(contentsOfURL: url),
            let shelf = Shelf(json: JSON(data: mockData)) else {
                XCTFail("Stream initializer failed" )
                return
        }
        
        XCTAssertNil( shelf.name )
        XCTAssertNil( shelf.title )
        XCTAssertNil( shelf.postCount )
        XCTAssertNil( shelf.streamUrl )
        XCTAssertNil( shelf.items )
        XCTAssertNil( shelf.previewImagesObject )
        XCTAssertNil( shelf.previewAsset )
        XCTAssertNil( shelf.previewImageAssets )
    }
    
    func testInvalid() {
        guard let url = NSBundle(forClass: self.dynamicType).URLForResource("Stream-Invalid", withExtension: "json" ),
            let mockData = NSData(contentsOfURL: url) else {
                XCTFail("Error reading mock json data" )
                return
        }
        XCTAssertNil(Shelf(json: JSON(data: mockData)))
    }
    
}
