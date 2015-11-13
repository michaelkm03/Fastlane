//
//  UpdateCommentRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/12/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import SwiftyJSON

/// Request for editing a particular comment
public struct UpdateCommentRequest: RequestType {
    
    public let commentID: Int64
    public let text: String
    
    public init(commentID: Int64, text: String) {
        self.commentID = commentID
        self.text = text
    }
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string: "/api/comment/edit")!
        let urlRequest = NSMutableURLRequest(URL: url)
        urlRequest.HTTPMethod = "POST"
        let params = [ "comment_id" : "\(commentID)", "text" : text ]
        urlRequest.vsdk_addURLEncodedFormPost(params)
        return urlRequest
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> Comment {
        guard let comment = Comment(json: responseJSON["payload"]) else {
            throw ResponseParsingError()
        }
        return comment
    }
}
