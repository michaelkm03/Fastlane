//
//  ContentTests.swift
//  victorious
//
//  Created by Vincent Ho on 5/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

@testable import VictoriousIOSSDK
import XCTest

class ContentTests: XCTestCase {
    
    func testValid() {
        guard let content: Content = createContentFromJSON(fileName: "Content") else {
            XCTFail("Failed to create Content from file.")
            return
        }
        
        XCTAssertEqual(content.id, "1")
        XCTAssertEqual(content.status, "public")
        XCTAssertEqual(content.text, "TEST_TITLE")
        XCTAssertTrue(content.hashtags.isEmpty)
        XCTAssertEqual(content.shareURL?.absoluteString, "SHARE_URL")
        XCTAssertEqual(Int(content.createdAt.value), 314159)
        XCTAssertEqual(content.previewImages.count, 4)
        XCTAssertEqual(content.assets.count, 1)
        XCTAssertEqual(content.type, ContentType.video)
        XCTAssertTrue(content.isLikedByCurrentUser)
    }
    
    func testInvalidID() {
        let viewedContent = createContentFromJSON(fileName: "ContentInvalidID")
        
        XCTAssertNil(viewedContent, "Viewed content should not have been created with an invalid JSON")
        
    }
    
    func testInvalidType() {
        let viewedContent = createContentFromJSON(fileName: "ContentInvalidType")
        
        XCTAssertNil(viewedContent, "Viewed content should not have been created with an invalid JSON")
        
    }
    
    func testInvalidPreviewType() {
        let viewedContent = createContentFromJSON(fileName: "ContentInvalidPreviewType")
        
        XCTAssertNil(viewedContent, "Viewed content should not have been created with an invalid JSON")
        
    }
    
    func testInvalidSourceType() {
        let viewedContent = createContentFromJSON(fileName: "ContentInvalidSourceType")
        
        XCTAssertNil(viewedContent, "Viewed content should not have been created with an invalid JSON")
        
    }

    func testValidChatMessage() {
        guard let chatMessage = createChatMessageFromJSON(fileName: "ChatMessage") else {
            XCTFail("Failed to create ChatMessage content from file.")
            return
        }

        XCTAssertEqual(chatMessage.text, "Test message")
        XCTAssertEqual(chatMessage.assets.count, 1)
        // FUTURE: Switch User.id to a String and enable this assertion.
//        XCTAssertEqual(chatMessage.author.id, "1")
        XCTAssertEqual(chatMessage.author.name, "Leetzor")
    }

    private func createChatMessageFromJSON(fileName fileName: String) -> Content? {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource(fileName, withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return nil
        }

        return Content(chatMessageJSON: JSON(data: mockData), serverTime: Timestamp(value: 1234567890))
    }

    private func createContentFromJSON(fileName fileName: String) -> Content? {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource(fileName, withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return nil
        }
        
        return Content(json: JSON(data: mockData))
    }
}
