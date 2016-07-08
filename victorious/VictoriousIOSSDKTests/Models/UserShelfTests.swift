//
//  UserShelfTests.swift
//  victorious
//
//  Created by Tian Lan on 1/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class UserShelfTests: XCTestCase {
    
    func testValid() {
        guard let url = NSBundle(forClass: self.dynamicType).URLForResource("UserShelfResponse", withExtension: "json" ),
            let mockData = NSData(contentsOfURL: url) else {
                XCTFail("Error reading mock json data" )
                return
        }
        guard let userShelf = UserShelf(json: JSON(data: mockData))else {
            XCTFail("UserShelf initializer failed")
            return
        }
        XCTAssertEqual(userShelf.followersCount, 22)
        
        let user = userShelf.user
        XCTAssertEqual(user.id, 3694)
        XCTAssertEqual(user.name, "Patrick Lynch")

        let shelf = userShelf.shelf
        XCTAssertEqual(shelf.streamID, "user:3694")
        XCTAssertEqual(shelf.type, .Shelf )
        XCTAssertEqual(shelf.subtype, .User)
        XCTAssertEqual(shelf.name, "Patrick Lynch")
        XCTAssertEqual(shelf.title, "RECOMMENDED PROFILE")
        XCTAssertEqual(shelf.postCount, 264)
        XCTAssertEqual(shelf.apiPath, "http://dev.getvictorious.com/api/sequence/detail_list_by_user/3694/%%PAGE_NUM%%/%%ITEMS_PER_PAGE%%")
        
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
        XCTAssertNil(UserShelf(json: JSON(data: mockData)))
    }
}
