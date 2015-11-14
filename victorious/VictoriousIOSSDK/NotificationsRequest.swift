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
    
    private let paginator: StandardPaginator
    
    public init(pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.init(paginator: StandardPaginator(pageNumber: pageNumber, itemsPerPage: itemsPerPage))
    }
    
    private init(paginator: StandardPaginator) {
        self.paginator = paginator
    }
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string: "/api/notification/notifications_list")!
        let request = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(request)
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> (results: [Notification], nextPage: NotificationsRequest?, previousPage: NotificationsRequest?) {
        
        guard let notificationsJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        let results = notificationsJSON.flatMap { Notification(json: $0) }
        
        let nextPageRequest: NotificationsRequest? = results.count > 0 ? NotificationsRequest(paginator: paginator.nextPage) : nil
        let previousPageRequest: NotificationsRequest?
        
        if let previousPage = paginator.previousPage {
            previousPageRequest = NotificationsRequest(paginator: previousPage)
        } else {
            previousPageRequest = nil
        }
        return (results, nextPageRequest, previousPageRequest)
    }
}
