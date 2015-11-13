//
//  DeleteCommentRequest.swift
//  victorious
//
//  Created by Tian Lan on 11/13/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct DeleteCommentRequest: RequestType {
    public let commentID: Int64
    public let removalReason: String?
    
    public init(commentID: Int64, removalReason: String?) {
        self.commentID = commentID
        self.removalReason = removalReason
    }
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/comment/remove")!)
        
        var commentInfo: [String: Any] = ["comment_id": commentID]
        if let reason = removalReason {
            commentInfo["removal_reason"] = reason
        }
        request.vsdk_addURLEncodedFormPost(commentInfo)
        
        return request
    }
}
