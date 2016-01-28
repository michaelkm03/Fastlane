//
//  FlagSequenceRequest.swift
//  victorious
//
//  Created by Patrick Lynch on 11/24/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct FlagSequenceRequest: RequestType {
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/sequence/flag")!)
        request.vsdk_addURLEncodedFormPost(["sequence_id": sequenceID])
        return request
    }
    
    private let sequenceID: String
    
    public init(sequenceID: String) {
        self.sequenceID = sequenceID
    }
}
