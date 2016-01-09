//
//  MockRequests.swift
//  victorious
//
//  Created by Tian Lan on 1/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK
import SwiftyJSON

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
