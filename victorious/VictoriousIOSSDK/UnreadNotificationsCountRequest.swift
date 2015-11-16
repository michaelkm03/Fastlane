//
//  UnreadNotificationsCountRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct UnreadNotificationsCountRequest: RequestType {
    
    public init() {}
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string: "/api/notification/unread_notification_count")!
        let request = NSMutableURLRequest(URL: url)
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> Int {
        guard let count = responseJSON["payload"]["unread_count"].int else {
            throw ResponseParsingError()
        }
        
        return count
    }
}
