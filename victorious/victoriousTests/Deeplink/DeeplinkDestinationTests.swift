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
    let hiddenURL = NSURL(string: "vthisapp://hiddenWebURL/https://www.example.com")!

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
        let expectedURL = NSURL(string: "https://www.example.com")!
        XCTAssertEqual(destination, .externalURL(url: expectedURL, addressBarVisible: true))
    }
    
    func testInitializeWithHiddenURL() {
        let destination = DeeplinkDestination(url: hiddenURL)
        let expectedURL = NSURL(string: "https://www.example.com")!
        XCTAssertEqual(destination, .externalURL(url: expectedURL, addressBarVisible: false))
    }
    
    func testInitializeWithContent() {
        let imageContent = Content(author: User(id: 123), id: "12345")
        let destination = DeeplinkDestination(content: imageContent)
        XCTAssertEqual(destination, .closeUp(contentWrapper: .content(content: imageContent)))
    }
    
    func testInitializeWithUserID() {
        let userID = 12345
        let destination = DeeplinkDestination(userID: userID)
        XCTAssertEqual(destination, DeeplinkDestination.profile(userID: userID))
    }
}
