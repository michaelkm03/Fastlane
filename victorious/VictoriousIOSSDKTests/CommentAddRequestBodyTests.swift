//
//  CommentAddRequestBodyTests.swift
//  victorious
//
//  Created by Patrick Lynch on 12/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON
@testable import VictoriousIOSSDK
import XCTest

class CommentAddRequestBodyTests: XCTestCase {
    
    var requestBodyWriter: CommentAddRequestBody!
    
    override func setUp() {
        super.setUp()
        
        self.requestBodyWriter = CommentAddRequestBody()
    }
    
    func testTextOnly() {
        let parameters = CommentParameters(
            sequenceID: "17100",
            text: "test",
            replyToCommentID: 1564,
            mediaURL: nil,
            mediaType: nil,
            realtimeComment: nil
        )
        
        let output = try! requestBodyWriter.write(parameters: parameters)
        let data = String(data: NSData(contentsOfURL: output.fileURL )!, encoding: NSUTF8StringEncoding)!
        XCTAssertEqual( data, "\r\n--M9EzbDHvJfWcrApoq3eUJWs3UF\r\nContent-Disposition: form-data; name=\"sequence_id\"\r\nContent-Type: text/plain; charset=UTF-8\r\n\r\n17100\r\n--M9EzbDHvJfWcrApoq3eUJWs3UF\r\nContent-Disposition: form-data; name=\"text\"\r\nContent-Type: text/plain; charset=UTF-8\r\n\r\ntest\r\n--M9EzbDHvJfWcrApoq3eUJWs3UF\r\nContent-Disposition: form-data; name=\"parent_id\"\r\nContent-Type: text/plain; charset=UTF-8\r\n\r\n1564\r\n--M9EzbDHvJfWcrApoq3eUJWs3UF--" )
    }
    
    func testRealtime() {
        let parameters = CommentParameters(
            sequenceID: "17100",
            text: "test",
            replyToCommentID: nil,
            mediaURL: nil,
            mediaType: nil,
            realtimeComment: CommentParameters.RealtimeComment(time: 0.54, assetID: 999)
        )
        
        let output = try! requestBodyWriter.write(parameters: parameters)
        let data = String(data: NSData(contentsOfURL: output.fileURL )!, encoding: NSUTF8StringEncoding)!
        XCTAssertEqual( data, "\r\n--M9EzbDHvJfWcrApoq3eUJWs3UF\r\nContent-Disposition: form-data; name=\"sequence_id\"\r\nContent-Type: text/plain; charset=UTF-8\r\n\r\n17100\r\n--M9EzbDHvJfWcrApoq3eUJWs3UF\r\nContent-Disposition: form-data; name=\"text\"\r\nContent-Type: text/plain; charset=UTF-8\r\n\r\ntest\r\n--M9EzbDHvJfWcrApoq3eUJWs3UF\r\nContent-Disposition: form-data; name=\"asset_id\"\r\nContent-Type: text/plain; charset=UTF-8\r\n\r\n999\r\n--M9EzbDHvJfWcrApoq3eUJWs3UF\r\nContent-Disposition: form-data; name=\"realtime\"\r\nContent-Type: text/plain; charset=UTF-8\r\n\r\n0.54\r\n--M9EzbDHvJfWcrApoq3eUJWs3UF--" )
    }
    
    func testMedia() {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("test_image", withExtension: "png") else {
            XCTFail("Error reading mock image")
            return
        }
        
        let parameters = CommentParameters(
            sequenceID: "17100",
            text: nil,
            replyToCommentID: nil,
            mediaURL: mockUserDataURL,
            mediaType: .Image,
            realtimeComment: nil
        )
        
        let output = try! requestBodyWriter.write(parameters: parameters)
        let data = NSData(contentsOfURL: output.fileURL )!
        XCTAssertNotNil( data )
        XCTAssertEqual( data.length, 83745 )
    }
}
