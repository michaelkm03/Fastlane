//
//  DeeplinkDestinationTests.swift
//  victorious
//
//  Created by Tian Lan on 7/25/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import victorious

class DeeplinkDestinationTests: XCTestCase {
    let contentURL = NSURL(string: "vthisapp://content/12345")!
    let profileURL = NSURL(string: "vthisapp://profile/12345")!
    let vipForumURL = NSURL(string: "vthisapp://vipForum")!
    let externalURL = NSURL(string: "vthisapp://webURL/https://www.example.com")!


    func testInitializeWithContentURL() {
        let destination = DeeplinkDestination(url: contentURL)
        
        XCTAssertEqual(destination, .closeUp(contentWrapper: .contentID(id: "12345")))
    }
    
    func testInitializeWithProfileURL() {
        let destination = DeeplinkDestination(url: profileURL)
        
        XCTAssertEqual(destination, .profile(userID: 12345))
    }
    
    func testInitializeWithVIPForumURL() {
        let destination = DeeplinkDestination(url: vipForumURL)
        
        XCTAssertEqual(destination, .vipForum)
    }
    
    func testInitializeWithExternalURL() {
        let destination = DeeplinkDestination(url: externalURL)
        
        XCTAssertEqual(destination, .externalURL(url: externalURL, addressBarVisible: true))
    }
    
    func testInitializeWithContent() {
        let imageContent = Content(id: "12345", createdAt: Timestamp(date: NSDate()) , postedAt: Timestamp(date: NSDate()), type: .image, text: "abc", assets: [], previewImages: [], author: User(id: 123))
        let destination1 = DeeplinkDestination(content: imageContent)
        XCTAssertEqual(destination1, .closeUp(contentWrapper: .content(content: imageContent)))
        
        let textContent = Content(id: "12346", createdAt: Timestamp(date: NSDate()) , postedAt: Timestamp(date: NSDate()), type: .text, text: "abc", assets: [], previewImages: [], author: User(id: 123))
        let destination2 = DeeplinkDestination(content: textContent)
        XCTAssertNil(destination2)
    }
    
    func testInitializeWithUserID() {
        let userID = 12345
        let destination = DeeplinkDestination(userID: userID)
        XCTAssertEqual(destination, DeeplinkDestination.profile(userID: userID))
    }
}
