//
//  RequestErrorTypeTests.swift
//  victorious
//
//  Created by Patrick Lynch on 11/24/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK
import XCTest

class RequestErrorTypeTests: XCTestCase {
    
    func testResponseParingError() {
        let message = "Failed to parse"
        let error = ResponseParsingError(localizedDescription: message)
        let nsError = NSError(error)
        XCTAssertEqual( nsError.localizedDescription, message )
    }
    
    func testAPIError() {
        let message = "API Error Occurred"
        let code = 9999
        let error = APIError(localizedDescription: message, code: code)
        let nsError = NSError(error)
        XCTAssertEqual( error.domain, APIError.errorTypeDomain )
        XCTAssertEqual( error.localizedDescription, message )
        XCTAssertEqual( error.description, message )
        XCTAssertEqual( nsError.localizedDescription, message )
        XCTAssertEqual( nsError.code, code )
    }
    
    func testAPIErrorDefaults() {
        let error = APIError()
        let nsError = NSError(error)
        XCTAssertEqual( error.domain, APIError.errorTypeDomain )
        XCTAssertEqual( error.localizedDescription, APIError.errorTypeDomain )
        XCTAssertEqual( error.description, APIError.errorTypeDomain )
        XCTAssertEqual( nsError.localizedDescription, APIError.errorTypeDomain )
        XCTAssertEqual( nsError.code, -1 )
    }
}
