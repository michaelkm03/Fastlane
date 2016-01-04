//
//  CommentFindRequest.swift
//  victorious
//
//  Created by Patrick Lynch on 12/2/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Finds and loads the page on which a particular comment is located,
/// designed for use with deep linking directly to a comment.
public struct CommentFindRequest: RequestType {
    
    public struct Result {
        public let comments: [Comment]
        public let pageNumber: Int
    }
    
    public let urlRequest: NSURLRequest
    
    private let sequenceID: String
    private let commentID: Int64
    
    public init( sequenceID: String, commentID: Int64, itemsPerPage: Int = 15 ) {
        self.sequenceID = sequenceID
        self.commentID = commentID
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/comment/find")! )
        request.URL = request.URL?.URLByAppendingPathComponent(String(sequenceID))
        request.URL = request.URL?.URLByAppendingPathComponent(String(commentID))
        request.URL = request.URL?.URLByAppendingPathComponent(String(itemsPerPage))
        self.urlRequest = request
    }
    
    public func parseResponse( response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON ) throws -> CommentFindRequest.Result {
        
        guard let commentsJSON = responseJSON["payload"].array,
            let pageNumber = responseJSON["page_number"].int else {
            throw ResponseParsingError()
        }
        
        return Result(comments: commentsJSON.flatMap { Comment(json: $0) }, pageNumber: pageNumber)
    }
}