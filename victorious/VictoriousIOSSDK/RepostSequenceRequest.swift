//
//  RepostSequenceRequest.swift
//  victorious
//
//  Created by Tian Lan on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct RepostSequenceRequest: RequestType {
    public let nodeID: Int
    
    public init(nodeID: Int) {
        self.nodeID = nodeID
    }
    
    public var urlRequest: NSURLRequest {
        let urlRequest = NSMutableURLRequest(URL: NSURL(string: "/api/repost/create")!)
        urlRequest.HTTPMethod = "POST"
        let repostSequenceInfo = [ "parent_node_id": nodeID ]
        urlRequest.vsdk_addURLEncodedFormPost(repostSequenceInfo)
        
        return urlRequest
    }
}
