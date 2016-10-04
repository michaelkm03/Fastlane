//
//  EndVIPEventRequestTests.swift
//  victorious
//
//  Created by Vincent Ho on 9/28/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import VictoriousIOSSDK
import XCTest

class EndVIPEventRequestTests: XCTestCase {
    func testRequest() {
        let request = EndVIPEventRequest(apiPath: APIPath(templatePath: "https://vapi-dev.getvictorious.com/v1/ws/app/1/close_sockets"))
        XCTAssertEqual(request?.urlRequest.url?.absoluteString, "https://vapi-dev.getvictorious.com/v1/ws/app/1/close_sockets")
    }
}
