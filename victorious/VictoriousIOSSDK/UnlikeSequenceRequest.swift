//
//  UnlikeSequenceRequest.swift
//  victorious
//
//  Created by Tian Lan on 11/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct UnlikeSequenceRequest: RequestType {
    public let sequenceID: Int64
    
    public init (sequenceID: Int64) {
        self.sequenceID = sequenceID
    }
    
    public var urlRequest: NSURLRequest {
        let urlRequest = NSMutableURLRequest(URL: NSURL(string: "/api/sequence/unlike")!)
        let unlikedSequenceInfo = [ "sequence_id": NSNumber(longLong: sequenceID) ]
        urlRequest.vsdk_addURLEncodedFormPost(unlikedSequenceInfo)
        
        return urlRequest
    }
}
