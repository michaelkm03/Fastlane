//
//  CommentAddRequestBodyTests.swift
//  victorious
//
//  Created by Patrick Lynch on 12/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

@testable import VictoriousIOSSDK
import XCTest

class CommentAddRequestBodyTests: XCTestCase {
    
    var requestBodyWriter: CommentRequestBodyWriter!
    
    func testTextOnly() {
        let parameters = Comment.CreationParameters(
            text: "test",
            sequenceID: "17100",
            replyToCommentID: 1564,
            mediaAttachment: nil,
            realtimeAttachment: nil
        )
        self.requestBodyWriter = CommentRequestBodyWriter(parameters: parameters)
        
        do {
            let output = try requestBodyWriter.write()
            let data = String(data: NSData(contentsOfURL: output.fileURL )!, encoding: NSUTF8StringEncoding)!
            XCTAssertEqual( data, "\r\n--M9EzbDHvJfWcrApoq3eUJWs3UF\r\nContent-Disposition: form-data; name=\"sequence_id\"\r\nContent-Type: text/plain; charset=UTF-8\r\n\r\n17100\r\n--M9EzbDHvJfWcrApoq3eUJWs3UF\r\nContent-Disposition: form-data; name=\"text\"\r\nContent-Type: text/plain; charset=UTF-8\r\n\r\ntest\r\n--M9EzbDHvJfWcrApoq3eUJWs3UF\r\nContent-Disposition: form-data; name=\"parent_id\"\r\nContent-Type: text/plain; charset=UTF-8\r\n\r\n1564\r\n--M9EzbDHvJfWcrApoq3eUJWs3UF--" )
        } catch {
            XCTFail( "Failed to write request body" )
        }
    }
    
    func testRealtime() {
        let parameters = Comment.CreationParameters(
            text: "test",
            sequenceID: "17100",
            replyToCommentID: nil,
            mediaAttachment: nil,
            realtimeAttachment: Comment.RealtimeAttachment(time: 0.54, assetID: 999)
        )
        self.requestBodyWriter = CommentRequestBodyWriter(parameters: parameters)
        
        do {
            let output = try requestBodyWriter.write()
            let data = String(data: NSData(contentsOfURL: output.fileURL )!, encoding: NSUTF8StringEncoding)!
            XCTAssertEqual( data, "\r\n--M9EzbDHvJfWcrApoq3eUJWs3UF\r\nContent-Disposition: form-data; name=\"sequence_id\"\r\nContent-Type: text/plain; charset=UTF-8\r\n\r\n17100\r\n--M9EzbDHvJfWcrApoq3eUJWs3UF\r\nContent-Disposition: form-data; name=\"text\"\r\nContent-Type: text/plain; charset=UTF-8\r\n\r\ntest\r\n--M9EzbDHvJfWcrApoq3eUJWs3UF\r\nContent-Disposition: form-data; name=\"asset_id\"\r\nContent-Type: text/plain; charset=UTF-8\r\n\r\n999\r\n--M9EzbDHvJfWcrApoq3eUJWs3UF\r\nContent-Disposition: form-data; name=\"realtime\"\r\nContent-Type: text/plain; charset=UTF-8\r\n\r\n0.54\r\n--M9EzbDHvJfWcrApoq3eUJWs3UF--" )
        } catch {
            XCTFail( "Failed to write request body" )
        }
    }
    
    func testMedia() {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("test_image", withExtension: "png") else {
            XCTFail("Error reading mock image")
            return
        }
        
        let parameters = Comment.CreationParameters(
            text: nil,
            sequenceID: "17100",
            replyToCommentID: nil,
            mediaAttachment: MediaAttachment(
                url: mockUserDataURL,
                type:.Image,
                thumbnailURL: mockUserDataURL,
                size: CGSize(width: 100.0, height: 100.0)
            ),
            realtimeAttachment: nil
        )
        self.requestBodyWriter = CommentRequestBodyWriter(parameters: parameters)
        
        do {
            let output = try requestBodyWriter.write()
            let data = NSData(contentsOfURL: output.fileURL )!
            XCTAssertNotNil( data )
            XCTAssertGreaterThan( data.length, 0 )
        } catch {
            XCTFail( "Failed to write request body" )
        }
    }
}
