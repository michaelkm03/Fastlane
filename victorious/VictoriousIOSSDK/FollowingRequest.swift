//
//  FollowingRequest.swift
//  victorious
//
//  Created by Tian Lan on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Retrieves a list of users followed by a specific user
public struct FollowingRequest: Pageable {
    
    public let urlRequest: NSURLRequest
    
    /// Users being followed will be retrieved by this user ID
    public let userID: Int64
    
    public let paginator: StandardPaginator
    
    public init(userID: Int64, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        let paginator = StandardPaginator(pageNumber: pageNumber, itemsPerPage: itemsPerPage)
        self.init(userID: userID, paginator: paginator)
    }
    
    public init( request: FollowingRequest, paginator: StandardPaginator ) {
        self.init( userID: request.userID, paginator: request.paginator)
    }
    
    private init(userID: Int64, paginator: StandardPaginator) {
        self.userID = userID
        self.paginator = paginator
        
        let url = NSURL(string: "/api/follow/subscribed_to_list/\(userID)")!
        let request = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(request)
        self.urlRequest = request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [User] {
        
        guard let usersJSON = responseJSON["payload"]["users"].array else {
            throw ResponseParsingError()
        }
        return usersJSON.flatMap { User(json: $0) }
    }
}
