//
//  NotificationsRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// Retrieves a list of notifications for the logged in user
public struct NotificationsRequest: PaginatorPageable, ResultBasedPageable {
    
    public let paginator: StandardPaginator
    
    public init(paginator: StandardPaginator = StandardPaginator() ) {
        self.paginator = paginator
    }
    
    public init(request: NotificationsRequest, paginator: StandardPaginator = StandardPaginator() ) {
        self.paginator = paginator
    }
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string: "/api/notification/notifications_list")!
        let request = NSMutableURLRequest(url: url as URL)
        paginator.addPaginationArgumentsToRequest(request)
        return request
    }
    
    public func parseResponse(response: URLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [Notification] {
        
        guard let notificationsJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        return notificationsJSON.flatMap { Notification(json: $0) }
    }
}
