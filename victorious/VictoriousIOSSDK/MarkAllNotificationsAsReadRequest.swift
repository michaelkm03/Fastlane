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
    
    public var urlRequest: URLRequest {
        var request = URLRequest(url: URL(string: "/api/notification/mark_all_notifications_read")!)
        request.httpMethod = "POST"
        return request
    }
}
