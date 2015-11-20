//
//  FlagSequenceRequest.swift
//  victorious
//
//  Created by Tian Lan on 11/13/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct FlagContentRequest: RequestType {
    
    public let urlRequest: NSURLRequest
    
    public init(sequenceID: Int64) {
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/sequence/flag")!)
        request.vsdk_addURLEncodedFormPost(["sequence_id": NSNumber(longLong: sequenceID)])
        self.urlRequest = request
    }
    
    public init(commentID: Int64) {
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/comment/flag")!)
        request.vsdk_addURLEncodedFormPost(["comment_id": NSNumber(longLong: commentID)])
        self.urlRequest = request
    }
}
