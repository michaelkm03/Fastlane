//
//  LikeSequenceRequest.swift
//  victorious
//
//  Created by Tian Lan on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct LikeSequenceRequest: RequestType {
    public let sequenceID: Int64
    
    public init (sequenceID: Int64) {
        self.sequenceID = sequenceID
    }
    
    public var urlRequest: NSURLRequest {
        let urlRequest = NSMutableURLRequest(URL: NSURL(string: "/api/sequence/like")!)
        urlRequest.HTTPMethod = "POST"
        let likedSequenceInfo = [ "sequence_id": sequenceID ]
        urlRequest.vsdk_addURLEncodedFormPost(likedSequenceInfo)
        
        return urlRequest
    }
}
