//
//  FollowersRequest.swift
//  victorious
//
//  Created by Tian Lan on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Retrieves a list of users who follows a specific user
public struct FollowersRequest: PaginatorPageable, ResultBasedPageable {
    
    public let urlRequest: NSURLRequest

    /// Followers will be retrieved by this user ID
    public let userID: Int64
    
    public let paginator: StandardPaginator
    
    public init(request: FollowersRequest, paginator: StandardPaginator ) {
        self.init( userID: request.userID, paginator: paginator )
    }
    
    public init(userID: Int64, paginator: StandardPaginator = StandardPaginator() ) {
        self.userID = userID
        self.paginator = paginator
        
        let url = NSURL(string: "/api/follow/followers_list/\(userID)")!
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
