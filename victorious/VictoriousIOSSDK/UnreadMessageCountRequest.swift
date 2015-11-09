//
//  UnreadMessageCountRequest.swift
//  victorious
//
//  Created by Michael Sena on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct UnreadMessageCountRequest: RequestType {
    
    public var urlRequest: NSURLRequest {
        let urlRequest = NSMutableURLRequest(URL: UnreadMessageCountRequest.basePath)
        return urlRequest
    }
    
    private static let basePath = NSURL(string: "/api/message/unread_message_count")!
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> Int {
        guard let unreadCount = responseJSON["payload"]["unread_count"].int else {
            throw ResponseParsingError()
        }
        return unreadCount
    }
    
    public init() {
        // So this is public
    }

}
