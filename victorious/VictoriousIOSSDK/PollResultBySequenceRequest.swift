//
//  PollResultBySequenceRequest.swift
//  victorious
//
//  Created by Tian Lan on 11/12/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct PollResultBySequenceRequest: RequestType {
    public let sequenceID: Int64
    
    public init(sequenceID: Int64) {
        self.sequenceID = sequenceID
    }
    
    public var urlRequest: NSURLRequest {
        return NSURLRequest(URL: NSURL(string: "/api/pollresult/summary_by_sequence/\(sequenceID)")!)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [VoteResult] {
        guard let voteResultsJSONArray = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        let voteResults = voteResultsJSONArray.flatMap { VoteResult(json: $0) }
        
        return voteResults
    }
}
 