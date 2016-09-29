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
    
    public var urlRequest: URLRequest {
        let url = URL(string: "/api/notification/notifications_list")!
        var request = URLRequest(url: url)
        paginator.addPaginationArguments(to: &request)
        return request
    }
    
    public func parseResponse(_ response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws -> [Notification] {
        
        guard let notificationsJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        return notificationsJSON.flatMap { Notification(json: $0) }
    }
}
