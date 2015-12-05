//
//  RequestOperationTests.swift
//  victorious
//
//  Created by Patrick Lynch on 11/19/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import XCTest
import VictoriousIOSSDK
import SwiftyJSON
@testable import victorious

struct MockRequest: RequestType {
    let urlRequest = NSURLRequest( URL: NSURL(string: "http://www.google.com" )! )
    func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> Bool {
        return true
    }
}

struct MockErrorRequest: RequestType {
    let urlRequest = NSURLRequest( URL: NSURL(string: "http://www.google.com" )! )
    func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> Bool {
        throw APIError( localizedDescription: "MockError", code: 999)
    }
}

class RequestOperationTests: XCTestCase {
    
    func testBasic() {
        
    }
    
    func testError() {
        
    }
}
