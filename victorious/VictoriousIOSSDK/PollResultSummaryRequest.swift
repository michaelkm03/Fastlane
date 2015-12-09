//
//  PollResultSummaryRequest.swift
//  victorious
//
//  Created by Tian Lan on 11/12/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct PollResultSummaryRequest: ResultBasedPageable, PaginatorPageable {
    
    public let paginator: StandardPaginator
    public let userID: Int64?
    public let sequenceID: Int64?
    
    public var urlRequest: NSURLRequest {
        let url: NSURL
        if let sequenceID = sequenceID {
            url = NSURL(string: "/api/pollresult/summary_by_sequence/\(sequenceID)")!
        } else if let userID = userID {
            url = NSURL(string: "/api/pollresult/summary_by_user/\(userID)")!
        }  else {
            abort()
        }
        return NSURLRequest(URL:  url)
    }
    
    public init(request: PollResultSummaryRequest, paginator: StandardPaginator) {
        self.paginator = paginator
        self.sequenceID = request.sequenceID
        self.userID = request.userID
    }
    
    public init(userID: Int64, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.sequenceID = nil
        self.userID = userID
        self.paginator = StandardPaginator(pageNumber: pageNumber, itemsPerPage: itemsPerPage)
    }
    
    public init(sequenceID: Int64, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.sequenceID = sequenceID
        self.userID = nil
        self.paginator = StandardPaginator(pageNumber: pageNumber, itemsPerPage: itemsPerPage)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [PollResult] {
        guard let voteResultsJSONArray = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        return voteResultsJSONArray.flatMap { PollResult(json: $0) }
    }
}
