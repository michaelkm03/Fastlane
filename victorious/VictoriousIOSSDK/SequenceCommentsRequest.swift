//
//  SequenceCommentsRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/12/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// Retrieves a list of comments for a certain sequence
public struct SequenceCommentsRequest: PaginatorPageable, ResultBasedPageable {
    
    /// Comments will be retrieved for the sequence with this ID
    public let sequenceID: String
    
    public let paginator: StandardPaginator
    
    public init(request: SequenceCommentsRequest, paginator: StandardPaginator ) {
        self.init( sequenceID: request.sequenceID, paginator: paginator )
    }
    
    public init(sequenceID: String, paginator: StandardPaginator = StandardPaginator() ) {
        self.paginator = paginator
        self.sequenceID = sequenceID
    }
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string: "/api/comment/all/\(sequenceID)")!
        let request = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(request)
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [Comment] {
        
        guard let commentsJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        return commentsJSON.flatMap { Comment(json: $0) }
    }
}
