//
//  PollResultBySequenceRequest.swift
//  victorious
//
//  Created by Tian Lan on 11/12/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct PollResultsRequest: RequestType {
    
    public let urlRequest: NSURLRequest
    
    public init(sequenceID: Int64) {
        self.urlRequest = NSURLRequest(URL: NSURL(string: "/api/pollresult/summary_by_sequence/\(sequenceID)")!)
    }
    
    public init(userID: Int64) {
        self.urlRequest = NSURLRequest(URL: NSURL(string: "/api/pollresult/summary_by_user/\(userID)")!)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [VoteResult] {
        guard let voteResultsJSONArray = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        return voteResultsJSONArray.flatMap { VoteResult(json: $0) }
    }
}
