//
//  FlagMessageRequest.swift
//  victorious
//
//  Created by Tian Lan on 11/13/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct FlagMessageRequest: RequestType {
    private let messageID: Int64
    
    public init(messageID: Int64) {
        self.messageID = messageID
    }
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/message/flag")!)
        request.vsdk_addURLEncodedFormPost(["message_id": messageID])
        
        return request
    }
}