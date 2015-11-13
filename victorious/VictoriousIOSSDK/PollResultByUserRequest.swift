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
    public let userID: Int64
    
    public init(userID: Int64) {
        self.userID = userID
    }
    
    public var urlRequest: NSURLRequest {
        return NSURLRequest(URL: NSURL(string: "/api/pollresult/summary_by_user/\(userID)")!)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [PollAnswer] {
        guard let votesJSONArray = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        let pollAnswers = votesJSONArray.flatMap { PollAnswer(json: $0) }
        
        return pollAnswers
    }
}
