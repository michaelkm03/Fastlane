//
//  DeleteSequenceRequest.swift
//  victorious
//
//  Created by Tian Lan on 11/13/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct DeleteSequenceRequest: RequestType {
    public let sequenceID: Int64
    
    public init(sequenceID: Int64) {
        self.sequenceID = sequenceID
    }
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/sequence/remove")!)
        request.vsdk_addURLEncodedFormPost(["sequence_id" : sequenceID])
        
        return request
    }
}