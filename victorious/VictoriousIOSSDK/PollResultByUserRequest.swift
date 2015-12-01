//
//  PollResultByUserRequest.swift
//  victorious
//
//  Created by Tian Lan on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct PollResultByUserRequest: RequestType {
    
    public let urlRequest: NSURLRequest
    
    public init(userID: Int64) {
        self.urlRequest = NSURLRequest(URL: NSURL(string: "/api/pollresult/summary_by_user/\(userID)")!)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [PollResult] {
        guard let votesJSONArray = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        return votesJSONArray.flatMap { PollResult(json: $0) }
    }
}
