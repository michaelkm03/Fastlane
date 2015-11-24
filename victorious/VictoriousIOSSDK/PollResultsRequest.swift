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
    
    private let url: NSURL
    
    public var urlRequest: NSURLRequest {
        return NSURLRequest(URL: url)
    }
    
    public init(sequenceID: Int64) {
        self.url = NSURL(string: "/api/pollresult/summary_by_sequence/\(sequenceID)")!
    }
    
    public init(userID: Int64) {
        self.url = NSURL(string: "/api/pollresult/summary_by_user/\(userID)")!
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [VoteResult] {
        guard let voteResultsJSONArray = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        return voteResultsJSONArray.flatMap { VoteResult(json: $0) }
    }
}
