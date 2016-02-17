//
//  MockRequests.swift
//  victorious
//
//  Created by Tian Lan on 1/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK
@testable import victorious
import SwiftyJSON

struct MockRequest: RequestType {
    let urlRequest = NSURLRequest( URL: NSURL(string: "http://www.mockrequest.com" )! )
    func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> Bool {
        return true
    }
}

struct MockErrorRequest: RequestType {
    
    let urlRequest: NSURLRequest
    let code: Int
    
    init(urlRequest: NSURLRequest = NSURLRequest( URL: NSURL(string: "http://www.mockerrorrequest.com" )! ), code: Int = 999) {
        self.urlRequest = urlRequest
        self.code = code
    }
    
    init(code: Int) {
        self.init(urlRequest:NSURLRequest( URL: NSURL(string: "http://www.mockerrorrequest.com" )! ), code:code)
    }
    
    func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> Bool {
        throw APIError( localizedDescription: "MockError", code: 999)
    }
}
