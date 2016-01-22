//
//  ListShelfTests.swift
//  victorious
//
//  Created by Tian Lan on 1/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
import SwiftyJSON

class ListShelfTests: XCTestCase {
    
    func testValid() {
        guard let url = NSBundle(forClass: self.dynamicType).URLForResource("PlayListShelfResponse", withExtension: "json" ),
            let mockData = NSData(contentsOfURL: url) else {
                XCTFail("Error reading mock json data" )
                return
        }
        guard let listShelf = ListShelf(json: JSON(data: mockData))else {
            XCTFail("UserShelf initializer failed")
            return
        }
        XCTAssertEqual(listShelf.caption, "Girl")
        
        let shelf = listShelf.shelf
        XCTAssertEqual(shelf.streamID, "15983")
        XCTAssertEqual(shelf.type, .Shelf )
        XCTAssertEqual(shelf.subtype, .Playlist)
        XCTAssertEqual(shelf.name, "Girl")
        XCTAssertEqual(shelf.title, "FEATURED PLAYLIST")
        XCTAssertNil(shelf.postCount)
        XCTAssertEqual(shelf.streamUrl, "http://dev.getvictorious.com/api/sequence/detail_list_by_stream_with_marquee/15983/0/%%PAGE_NUM%%/%%ITEMS_PER_PAGE%%")
        
        XCTAssertEqual(shelf.items?.count, 8)
        XCTAssertEqual(shelf.items?.filter { $0 is Sequence }.count, 8)
        XCTAssertEqual(shelf.items?.filter { $0 is Stream }.count, 0)
        
        XCTAssertNil((shelf.previewImagesObject))
        XCTAssertNil(shelf.previewTextPostAsset)
        XCTAssertEqual(shelf.previewImageAssets?.count, 3)
    }
    
    func testInvalid() {
        guard let url = NSBundle(forClass: self.dynamicType).URLForResource("SimpleStream", withExtension: "json" ),
            let mockData = NSData(contentsOfURL: url) else {
                XCTFail("Error reading mock json data" )
                return
        }
        XCTAssertNil(ListShelf(json: JSON(data: mockData)))
    }
}
