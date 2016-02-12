//
//  FriendFindByFacebookRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 2/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK

class FriendFindByFacebookRequestTests: XCTestCase {

    let token = "TestFacebookToken"
    let facebook = FriendFindSocialNetwork.Facebook(accessToken: "token")

    func testRequest() {
        let request = FriendFindByFacebookRequest(socialNetwork: facebook)
        
    }
}
