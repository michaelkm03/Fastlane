//
//  CreateChatServiceTokenRequestTests.swift
//  victorious
//
//  Created by Sebastian Nystorm on 12/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import XCTest
@testable import VictoriousIOSSDK

class CreateChatServiceTokenRequestTests: XCTestCase {
    
    private let apiPath = APIPath(templatePath: "https://vapi-dev.getvictorious.com/v1/users/%%USER_ID%%/chat/token")
    private let userID = 1337
    
    func testInitialization() {
        let request = CreateChatServiceTokenRequest(apiPath: apiPath, currentUserID: userID)
        XCTAssertNotNil(request, "Expected CreateChatServiceTokenRequest to be created with valied data.")
        
        let expandedURLString = "https://vapi-dev.getvictorious.com/v1/users/1337/chat/token"
        let url = NSURL(string: expandedURLString)!
        
        XCTAssertEqual(url.baseURL, request?.baseURL)
        XCTAssertEqual(url, request?.urlRequest.URL)
    }
}
