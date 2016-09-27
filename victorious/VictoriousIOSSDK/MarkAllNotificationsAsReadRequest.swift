//
//  MarkAllNotificationsAsReadRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// Marks all notifications as having been read
public struct MarkAllNotificationsAsReadRequest: RequestType {
    
    public init() {}
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(url: NSURL(string: "/api/notification/mark_all_notifications_read")! as URL)
        request.httpMethod = "POST"
        return request
    }
}
