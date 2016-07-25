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
    func testInitializeWithURL() {
        var destination: DeeplinkDestination?
        
        let contentURL = NSURL(string: "vthisapp://content/12345")!
        destination = DeeplinkDestination(url: contentURL)
    }
}
