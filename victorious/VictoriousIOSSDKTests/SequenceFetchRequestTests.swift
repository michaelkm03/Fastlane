//
//  SequenceFetchRequestTests.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import VictoriousIOSSDK

class SequenceFetchRequestTests: XCTestCase {
    
    func testConfiguredRequest() {
        let id: Int64 = 3694
        let request =  SequenceFetchRequest(sequenceID: id )
        XCTAssertEqual( request.urlRequest.URL, NSURL(string: "/api/sequence/fetch/\(id)") )
        XCTAssertEqual( request.sequenceID, id )
        XCTAssertEqual( request.urlRequest.HTTPMethod, "GET" )
    }
    
    func testParseResponse() {
        
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("SequenceFetchResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        let id: Int64 = 17143
        let request =  SequenceFetchRequest(sequenceID: id)
        let sequence: Sequence
        do {
            sequence = try request.parseResponse(NSURLResponse(), toRequest: NSURLRequest(), responseData: mockData, responseJSON: JSON(data: mockData))
        } catch {
            XCTFail("parseResponse is not supposed to throw")
            return
        }
        
        let dateFormatter = NSDateFormatter( format: DateFormat.Standard )
        let releasedAtDate = dateFormatter.dateFromString( "2015-11-18 00:23:29" )
        
        XCTAssertEqual( sequence.sequenceID, id )
        XCTAssertEqual( sequence.category, Sequence.Category.UGCVideoRepost )
        XCTAssertEqual( sequence.releasedAt, releasedAtDate )
        XCTAssertEqual( sequence.user.userID, Int64(3694) )
        XCTAssertEqual( sequence.parentUser!.userID, Int64(3694) )
        XCTAssertEqual( sequence.nodes.count, 1 )
        XCTAssertEqual( sequence.type, StreamContentType.Sequence )
        XCTAssertEqual( sequence.subtype, StreamContentType.Video )
        XCTAssertEqual( sequence.name, "Patrick's Fantastic Sequence" )
        XCTAssertEqual( sequence.previewData as? String, "http://media-dev-public.s3-website-us-west-1.amazonaws.com/6e063eaca658538013574646353759e8/thumbnail-00001.jpg" )
        XCTAssertNotNil( sequence.tracking )
        XCTAssertNotNil( sequence.endCard )
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
        
        // TODO: When other models are done
        /*XCTAssertEqual( sequence.comments, )
        XCTAssertEqual( sequence.likers, )
        XCTAssertEqual( sequence.voteResults, )
        XCTAssertEqual( sequence.recentComments, )
        XCTAssertEqual( sequence.adBreaks, )*/
    }
}
