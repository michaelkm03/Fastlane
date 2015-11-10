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
        
        XCTAssertEqual( stream.remoteID, "13396" )
        XCTAssertEqual( stream.type, .Shelf )
        XCTAssertEqual( stream.subtype, .Marquee )
        XCTAssertEqual( stream.streamContentType, .Sequence )
        XCTAssertEqual( stream.name, "Following Stream Marquee" )
        XCTAssertEqual( stream.title, "Marquee" )
        XCTAssertEqual( stream.postCount, 2 )
        XCTAssertEqual( stream.streamUrl, "http://dev.getvictorious.com/api/sequence/detail_list_by_stream_with_marquee/13396/0/%%PAGE_NUM%%/%%ITEMS_PER_PAGE%%" )
        XCTAssertEqual( stream.items.count, 3 )
        XCTAssertEqual( stream.items.filter { $0 is Sequence }.count, 2)
        XCTAssertEqual( stream.items.filter { $0 is Stream }.count, 1)
        XCTAssertEqual( (stream.previewImagesObject as! [String]).count, 3 )
        XCTAssertEqual( stream.previewTextPostAsset, "http://media-dev-public.s3-website-us-west-1.amazonaws.com/f4c9b9fc3564e4af36e61e5b1ce78ec2/thumbnail-00001.jpg" )
        XCTAssertEqual( stream.previewImageAssets.count, 0 )
    }
    
    func testDefaults() {
        let data = "{ \"id\" : \"21321\" }".dataUsingEncoding(NSUTF8StringEncoding)!
        guard let stream = Stream(json: JSON(data: data)) else {
            XCTFail("Stream initializer failed" )
            return
        }
        
        XCTAssertEqual( stream.remoteID, "21321" )
        XCTAssertNil( stream.type )
        XCTAssertNil( stream.subtype )
        XCTAssertNil( stream.streamContentType )
        XCTAssertEqual( stream.name, "" )
        XCTAssertEqual( stream.title, "" )
        XCTAssertEqual( stream.postCount, 0 )
        XCTAssertEqual( stream.streamUrl, "" )
        XCTAssertEqual( stream.items.count, 0 )
        XCTAssertNil( stream.previewImagesObject )
        XCTAssertNil( stream.previewTextPostAsset )
        XCTAssertEqual( stream.previewImageAssets.count, 0 )
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
