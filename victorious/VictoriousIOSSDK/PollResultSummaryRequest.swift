//
//  PollResultSummaryRequest.swift
//  victorious
//
//  Created by Tian Lan on 11/12/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct PollResultSummaryRequest: ResultBasedPageable, PaginatorPageable {
    
    public let paginator: StandardPaginator
    public let userID: Int?
    public let sequenceID: String?
    
    private let url: NSURL
    
    public var urlRequest: NSURLRequest {
        return NSURLRequest(URL:  url)
    }
    
    public init(request: PollResultSummaryRequest, paginator: StandardPaginator) {
        self.paginator = paginator
        self.sequenceID = request.sequenceID
        self.userID = request.userID
        self.url = request.url
    }
    
    public init(userID: Int, paginator: StandardPaginator = StandardPaginator() ) {
        self.sequenceID = nil
        self.userID = userID
        self.paginator = paginator
        self.url = NSURL(string: "/api/pollresult/summary_by_user/\(userID)")!
    }
    
    public init(sequenceID: String, paginator: StandardPaginator = StandardPaginator() ) {
        self.sequenceID = sequenceID
        self.userID = nil
        self.paginator = paginator
        url = NSURL(string: "/api/pollresult/summary_by_sequence/\(sequenceID)")!
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [PollResult] {
        guard let voteResultsJSONArray = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        return voteResultsJSONArray.flatMap { PollResult(json: $0) }
    }
}
