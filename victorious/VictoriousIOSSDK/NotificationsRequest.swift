//
//  NotificationsRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/11/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Retrieves a list of notifications for the logged in user
public struct NotificationsRequest: Pageable {
    
    public let paginator: StandardPaginator
    
    public init(pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.paginator = StandardPaginator(pageNumber: pageNumber, itemsPerPage: itemsPerPage)
    }
    
    public init(request: NotificationsRequest, paginator: StandardPaginator) {
        self.paginator = paginator
    }
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string: "/api/notification/notifications_list")!
        let request = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(request)
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [Notification] {
        
        guard let notificationsJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        let output = notificationsJSON.flatMap { Notification(json: $0) }
        self.paginator.resultCount = output.count
        return output
    }
}
