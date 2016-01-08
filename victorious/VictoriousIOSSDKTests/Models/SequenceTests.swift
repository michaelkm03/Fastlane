//
//  SequenceTests.swift
//  victorious
//
//  Created by Patrick Lynch on 11/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON
import VictoriousIOSSDK
import XCTest

class SequenceTests: XCTestCase {
    
    func testValid() {
        guard let url = NSBundle(forClass: self.dynamicType).URLForResource("Sequence", withExtension: "json" ),
            let mockData = NSData(contentsOfURL: url) else {
                XCTFail("Error reading mock json data" )
                return
        }
        guard let sequence = Sequence(json: JSON(data: mockData)) else {
            XCTFail("Sequence initializer failed" )
            return
        }
        
        let dateFormatter = NSDateFormatter( format: DateFormat.Standard )
        let releasedAtDate = dateFormatter.dateFromString( "2015-11-18 00:23:29" )
        
        XCTAssertEqual( sequence.sequenceID, "17143" )
        XCTAssertEqual( sequence.category, Sequence.Category.UGCVideoRepost )
        XCTAssertEqual( sequence.releasedAt, releasedAtDate )
        XCTAssertEqual( sequence.user.userID, Int(3694) )
        XCTAssertEqual( sequence.parentUser?.userID, Int(3694) )
        XCTAssertEqual( sequence.nodes?.count, 1 )
        XCTAssertEqual( sequence.type, StreamContentType.Sequence )
        XCTAssertEqual( sequence.subtype, StreamContentType.Video )
        XCTAssertEqual( sequence.name, "Patrick's Fantastic Sequence" )
        XCTAssertEqual( sequence.previewData as? String, "http://media-dev-public.s3-website-us-west-1.amazonaws.com/6e063eaca658538013574646353759e8/thumbnail-00001.jpg" )
        XCTAssertNotNil( sequence.tracking )
        XCTAssertEqual( sequence.headline, "Headline!!!" )
        XCTAssertEqual( sequence.sequenceDescription, "Describe me a sequence, yo" )
        XCTAssertEqual( sequence.hasReposted, true)
        XCTAssertEqual( sequence.isComplete, true)
        XCTAssertEqual( sequence.isLikedByMainUser, true)
        XCTAssertEqual( sequence.isRemix, true)
        XCTAssertEqual( sequence.isRepost, true)
        XCTAssertEqual( sequence.commentCount, 1)
        XCTAssertEqual( sequence.repostCount, 3)
        XCTAssertEqual( sequence.gifCount, 4)
        XCTAssertEqual( sequence.likeCount, 5)
        XCTAssertEqual( sequence.memeCount, 6)
        XCTAssertEqual( sequence.permissionsMask, 3486)
        XCTAssertEqual( sequence.nameEmbeddedInContent, true)
        XCTAssertEqual( sequence.previewType, AssetType.Media )
        XCTAssertEqual( sequence.trendingTopicName, "Trending Topic!!")
        XCTAssertEqual( sequence.comments?.count, 1 )
        XCTAssertEqual( sequence.recentComments?.count, 1 )
    }
    
    func testDefaults() {
        guard let url = NSBundle(forClass: self.dynamicType).URLForResource("SimpleSequence", withExtension: "json" ),
            let mockData = NSData(contentsOfURL: url),
            let sequence = Sequence(json: JSON(data: mockData)) else {
                XCTFail("Stream initializer failed" )
                return
        }
        
        let dateFormatter = NSDateFormatter( format: DateFormat.Standard )
        let releasedAtDate = dateFormatter.dateFromString( "2015-11-18 00:23:29" )
        
        XCTAssertEqual( sequence.sequenceID, "17143" )
        XCTAssertEqual( sequence.category, Sequence.Category.UGCVideoRepost )
        XCTAssertEqual( sequence.releasedAt, releasedAtDate )
        XCTAssertEqual( sequence.type, StreamContentType.Sequence )
        XCTAssertEqual( sequence.subtype, StreamContentType.Video )
        XCTAssertEqual( sequence.user.userID, Int(3694) )
        XCTAssertNil( sequence.nodes )
    }
}
