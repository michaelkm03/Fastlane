//
//  StreamTests.swift
//  victorious
//
//  Created by Patrick Lynch on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class StreamTests: XCTestCase {
    
    func testValid() {
        guard let url = NSBundle(forClass: self.dynamicType).URLForResource("Stream", withExtension: "json" ),
            let mockData = NSData(contentsOfURL: url) else {
                XCTFail("Error reading mock json data" )
                return
        }
        guard let stream = Stream(json: JSON(data: mockData)) else {
            XCTFail("Stream initializer failed" )
            return
        }
        
        XCTAssertEqual( stream.streamID, "13396" )
        XCTAssertEqual( stream.type, StreamContentType.Shelf )
        XCTAssertEqual( stream.subtype, StreamContentType.Marquee )
        XCTAssertEqual( stream.streamContentType, StreamContentType.Sequence )
        XCTAssertEqual( stream.name, "Following Stream Marquee" )
        XCTAssertEqual( stream.title, "Marquee" )
        XCTAssertEqual( stream.postCount, 2 )
        XCTAssertEqual( stream.streamUrl, "http://dev.getvictorious.com/api/sequence/detail_list_by_stream_with_marquee/13396/0/%%PAGE_NUM%%/%%ITEMS_PER_PAGE%%" )
        XCTAssertEqual( stream.items?.count, 3 )
        XCTAssertEqual( stream.items?.filter { $0 is Sequence }.count, 2)
        XCTAssertEqual( stream.items?.filter { $0 is Stream }.count, 1)
        XCTAssertEqual( (stream.previewImagesObject as! [String]).count, 3 )
        XCTAssertNil( stream.previewTextPostAsset )
        XCTAssertNil( stream.previewImageAssets )
    }
    
    func testDefaults() {
        guard let url = NSBundle(forClass: self.dynamicType).URLForResource("SimpleStream", withExtension: "json" ),
            let mockData = NSData(contentsOfURL: url),
            let stream = Stream(json: JSON(data: mockData)) else {
                XCTFail("Stream initializer failed" )
                return
        }
        
        XCTAssertNil( stream.name )
        XCTAssertNil( stream.title )
        XCTAssertNil( stream.postCount )
        XCTAssertNil( stream.streamUrl )
        XCTAssertNil( stream.items )
        XCTAssertNil( stream.previewImagesObject )
        XCTAssertNil( stream.previewTextPostAsset )
        XCTAssertNil( stream.previewImageAssets )
    }
    
    func testInvalid() {
        guard let url = NSBundle(forClass: self.dynamicType).URLForResource("Stream-Invalid", withExtension: "json" ),
            let mockData = NSData(contentsOfURL: url) else {
                XCTFail("Error reading mock json data" )
                return
        }
        XCTAssertNil( Stream(json: JSON(data: mockData) ) )
    }
}
