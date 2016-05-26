//
//  SequenceTests.swift
//  victorious
//
//  Created by Patrick Lynch on 11/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

@testable import VictoriousIOSSDK
import XCTest

class SequenceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testValid() {
        guard let sequence: Sequence = createAdSequenceFromJSON(fileName: "Sequence") else {
            XCTFail("Failed to create a Sequence")
            return
        }

        let dateFormatter = NSDateFormatter( vsdk_format: DateFormat.Standard )
        let releasedAtDate = dateFormatter.dateFromString( "2015-11-18 00:23:29" )
        
        XCTAssertEqual( sequence.sequenceID, "17143" )
        XCTAssertEqual( sequence.category, Sequence.Category.UGCVideoRepost )
        XCTAssertEqual( sequence.releasedAt, releasedAtDate )
        XCTAssertEqual( sequence.user.id, Int(3694) )
        XCTAssertEqual( sequence.parentUser?.id, Int(3694) )
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
        XCTAssertEqual( sequence.likeCount, 5)
        XCTAssertEqual( sequence.memeCount, 6)
        XCTAssertEqual( sequence.permissionsMask, 3486)
        XCTAssertEqual( sequence.nameEmbeddedInContent, true)
        XCTAssertEqual( sequence.previewType, AssetType.Media )
        XCTAssertEqual( sequence.trendingTopicName, "Trending Topic!!")
        XCTAssertEqual( sequence.voteTypes?.count, 5)
        XCTAssertEqual( sequence.voteTypes?.first?.voteID, "16")
        XCTAssertEqual( sequence.voteTypes?.first?.voteCount, 2)
        XCTAssertEqual( sequence.voteTypes?.last?.voteID, "8")
        XCTAssertEqual( sequence.voteTypes?.last?.voteCount, 3)
    }

    func testInvalid() {
        let sequenceWithoutUser: Sequence? = createAdSequenceFromJSON(fileName: "SequenceWithoutUser")
        XCTAssertNil(sequenceWithoutUser)
        let sequenceWithoutCategory: Sequence? = createAdSequenceFromJSON(fileName: "SequenceWithoutCategory")
        XCTAssertNil(sequenceWithoutCategory)
        let sequenceWithoutID: Sequence? = createAdSequenceFromJSON(fileName: "SequenceWithoutID")
        XCTAssertNil(sequenceWithoutID)
    }

    func testDefaults() {
        guard let sequence: Sequence = createAdSequenceFromJSON(fileName: "SequenceSimple") else {
            XCTFail("Failed to create a Sequence")
            return
        }
        
        let dateFormatter = NSDateFormatter( vsdk_format: DateFormat.Standard )
        let releasedAtDate = dateFormatter.dateFromString( "2015-11-18 00:23:29" )
        
        XCTAssertEqual( sequence.sequenceID, "17143" )
        XCTAssertEqual( sequence.category, Sequence.Category.UGCVideoRepost )
        XCTAssertEqual( sequence.releasedAt, releasedAtDate )
        XCTAssertEqual( sequence.type, StreamContentType.Sequence )
        XCTAssertEqual( sequence.subtype, StreamContentType.Video )
        XCTAssertEqual( sequence.user.id, Int(3694) )
        XCTAssertNil( sequence.nodes )
    }

    func testAdBreaks() {
        guard let sequence: Sequence = createAdSequenceFromJSON(fileName: "SequenceWithAdBreak") else {
            XCTFail("Failed to create a Sequence")
            return
        }

        guard let adBreak = sequence.adBreak else {
            XCTFail("No adBreak on a sequence")
            return
        }

        let testAdTag = "https://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/124319096/external/ad_rule_samples" +
            "&ciu_szs=300x250&ad_rule=1&impl=s&gdfp_req=1&env=vp&output=vmap&unviewed_position_start=1" +
            "&cust_params=deployment%3Ddevsite%26sample_ar%3Dpreonly&cmsid=496&vid=short_onecue&correlator="
        XCTAssertEqual(5, adBreak.adSystemID)
        XCTAssertEqual(7000, adBreak.timeout)
        XCTAssertEqual(testAdTag, adBreak.adTag)
    }

    private func createAdSequenceFromJSON(fileName fileName: String) -> Sequence? {
        guard let url = NSBundle(forClass: self.dynamicType).URLForResource(fileName, withExtension: "json") else {
            XCTFail("Failed to find mock data with name \(fileName).json")
            return nil
        }

        guard let sequence = Sequence(url: url) else {
            return nil
        }

        return sequence
    }
}
