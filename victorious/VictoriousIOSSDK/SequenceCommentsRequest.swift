//
//  SequenceCommentsRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/12/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Retrieves a list of comments for a certain sequence
public struct SequenceCommentsRequest: Pageable {
    
    /// Comments will be retrieved for the sequence with this ID
    public let sequenceID: Int64
    
    private let paginator: StandardPaginator
    
    public init(sequenceID: Int64, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.init(sequenceID: sequenceID, paginator: StandardPaginator(pageNumber: pageNumber, itemsPerPage: itemsPerPage))
    }
    
    private init(sequenceID: Int64, paginator: StandardPaginator) {
        self.sequenceID = sequenceID
        self.paginator = paginator
    }
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string: "/api/comment/all/\(sequenceID)")!
        let request = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(request)
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> (results: [Comment], nextPage: SequenceCommentsRequest?, previousPage: SequenceCommentsRequest?) {
        
        guard let commentsJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        let results = commentsJSON.flatMap { Comment(json: $0) }
        let nextPageRequest: SequenceCommentsRequest? = commentsJSON.count > 0 ? SequenceCommentsRequest(sequenceID: sequenceID, paginator: paginator.nextPage) : nil
        let previousPageRequest: SequenceCommentsRequest?
        
        if let previousPage = paginator.previousPage {
            previousPageRequest = SequenceCommentsRequest(sequenceID: sequenceID, paginator: previousPage)
        } else {
            previousPageRequest = nil
        }
        return (results, nextPageRequest, previousPageRequest)
    }
}
