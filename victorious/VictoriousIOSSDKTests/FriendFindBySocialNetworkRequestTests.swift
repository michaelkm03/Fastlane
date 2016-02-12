//
//  FriendFindBySocialNetworkRequestTests.swift
//  victorious
//
//  Created by Tian Lan on 2/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
import SwiftyJSON

class FriendFindBySocialNetworkRequestTests: XCTestCase {

    let token = "TestFacebookToken"
    let facebook = FriendFindSocialNetwork.Facebook(platformName: "Facebook", accessToken: "token")

    func testRequest() {
        let request = FriendFindBySocialNetworkRequest(socialNetwork: facebook)
        XCTAssertEqual(request.urlRequest.URL!.absoluteString, "/api/friend/find")
    }
    
    func testParseResponse() {
        guard let mockUserDataURL = NSBundle(forClass: self.dynamicType).URLForResource("FriendFindByEmailResponse", withExtension: "json"),
            let mockData = NSData(contentsOfURL: mockUserDataURL) else {
                XCTFail("Error reading mock json data")
                return
        }
        
        let request = FriendFindBySocialNetworkRequest(socialNetwork: facebook)
        
        do {
            let foundFriends = try request.parseResponse(NSURLResponse(), toRequest: NSURLRequest(), responseData: mockData, responseJSON: JSON(data: mockData))
            XCTAssertFalse(foundFriends.isEmpty)
            if let firstUser = foundFriends.first {
                XCTAssertEqual(firstUser.name, "Mikes")
            } else {
                XCTFail("we should have at least one user here")
            }
        } catch {
            XCTFail("parseResponse is not supposed to throw")
            return
        }
    }
}
