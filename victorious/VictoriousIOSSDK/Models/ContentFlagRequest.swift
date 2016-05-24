//
//  ContentFlagRequest.swift
//  victorious
//
//  Created by Vincent Ho on 5/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct ContentFlagRequest: RequestType {
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/sequence/flag")!)
        request.vsdk_addURLEncodedFormPost(["sequence_id": contentID])
        return request
    }
    
    private let contentID: String
    
    public init(contentID: String) {
        self.contentID = contentID
    }
}
