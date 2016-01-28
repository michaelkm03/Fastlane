//
//  FlagConversationRequest.swift
//  victorious
//
//  Created by Michael Sena on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

public struct FlagConversationRequest: RequestType {
    public let mostRecentMessageID: Int
    private static let basePath = NSURL(string: "/api/message/flag")!
    
    public init(mostRecentMessageID: Int) {
        self.mostRecentMessageID = mostRecentMessageID
    }
    
    public var urlRequest: NSURLRequest {
        let urlRequest = NSMutableURLRequest(URL: FlagConversationRequest.basePath)
        urlRequest.vsdk_addURLEncodedFormPost( ["message_id" : String(mostRecentMessageID)] )
        return urlRequest
    }
}
