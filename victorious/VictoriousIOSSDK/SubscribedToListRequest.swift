//
//  SubscribedToListRequest.swift
//  victorious
//
//  Created by Tian Lan on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// Retrieves a list of users followed by a specific user
public struct SubscribedToListRequest: PaginatorPageable, ResultBasedPageable {
    
    public let urlRequest: NSURLRequest
    
    /// Users being followed will be retrieved by this user ID
    public let userID: Int
    
    public let paginator: StandardPaginator
    
    public init( request: SubscribedToListRequest, paginator: StandardPaginator ) {
        self.init( userID: request.userID, paginator: paginator)
    }
    
    public init(userID: Int, paginator: StandardPaginator = StandardPaginator(pageNumber: 1, itemsPerPage: 30) ) {
        self.userID = userID
        self.paginator = paginator
        
        let url = NSURL(string: "/api/follow/subscribed_to_list/\(userID)")!
        let request = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(request)
        self.urlRequest = request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [User] {
        
        guard let usersJSON = responseJSON["payload"]["users"].array ?? responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        return usersJSON.flatMap { User(json: $0) }
    }
}
