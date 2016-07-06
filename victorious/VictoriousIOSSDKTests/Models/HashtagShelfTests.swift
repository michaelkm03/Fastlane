//
//  HashtagShelfTests.swift
//  victorious
//
//  Created by Tian Lan on 1/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class HashtagShelfTests: XCTestCase {
    
    func testValid() {
        guard let url = NSBundle(forClass: self.dynamicType).URLForResource("FeaturedHashtagResponse", withExtension: "json" ),
            let mockData = NSData(contentsOfURL: url) else {
                XCTFail("Error reading mock json data" )
                return
        }
        guard let hashtagShelf = HashtagShelf(json: JSON(data: mockData))else {
            XCTFail("UserShelf initializer failed")
            return
        }
        let hashtag = hashtagShelf.hashtag
        XCTAssertEqual(hashtag.tag, "test")
        
        let shelf = hashtagShelf.shelf
        XCTAssertEqual(shelf.streamID, "15139")
        XCTAssertEqual(shelf.type, .Shelf )
        XCTAssertEqual(shelf.subtype, .Hashtag)
        XCTAssertEqual(shelf.name, "#test")
        XCTAssertEqual(shelf.title, "FEATURED HASHTAG")
        XCTAssertEqual(shelf.postCount, 1)
        XCTAssertEqual(shelf.apiPath, "http://dev.getvictorious.com/api/sequence/detail_list_by_stream_with_marquee/15139/0/%%PAGE_NUM%%/%%ITEMS_PER_PAGE%%")
        
        XCTAssertEqual(shelf.items?.count, 10)
        XCTAssertEqual(shelf.items?.filter { $0 is Sequence }.count, 10)
        XCTAssertEqual(shelf.items?.filter { $0 is Stream }.count, 0)
        
        XCTAssertNil(shelf.previewImagesObject)
        XCTAssertNil(shelf.previewAsset)
        XCTAssertNil(shelf.previewImageAssets)
    }
    
    func testInvalid() {
        guard let url = NSBundle(forClass: self.dynamicType).URLForResource("SimpleStream", withExtension: "json" ),
            let mockData = NSData(contentsOfURL: url) else {
                XCTFail("Error reading mock json data" )
                return
        }
        XCTAssertNil(HashtagShelf(json: JSON(data: mockData)))
    }
}
