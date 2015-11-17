//
//  CommentTests.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON
import VictoriousIOSSDK
import XCTest

class CommentTests: XCTestCase {
    
    func testJSONParsing() {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("Comment", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        guard let comment = Comment(json: JSON(data: mockData)) else {
            XCTFail("Hashtag initializer failed")
            return
        }
        XCTAssertEqual(comment.remoteID, 28543)
        XCTAssertEqual(comment.displayOrder, 1)
        XCTAssertEqual(comment.userID, 5160)
        XCTAssertEqual(comment.shouldAutoplay, false)
        XCTAssertEqual(comment.user.name, "Ryan Higa")
        XCTAssertEqual(comment.text, "test")
        XCTAssertNil(comment.mediaType)
        XCTAssertEqual(comment.mediaURL, NSURL(string: ""))
        XCTAssertEqual(comment.thumbnailURL, NSURL(string: ""))
        XCTAssertEqual(comment.flags, 0)
        let dateFormatter = NSDateFormatter(format: .Standard)
        XCTAssertEqual(dateFormatter.stringFromDate(comment.postedAt), "2015-11-12 02:18:54")
    }
}
