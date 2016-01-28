//
//  FollowersListRequest.swift
//  victorious
//
//  Created by Tian Lan on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Retrieves a list of users who follows a specific user
public struct FollowersListRequest: PaginatorPageable, ResultBasedPageable {
    
    public let urlRequest: NSURLRequest

    public let userID: Int
    
    public let paginator: StandardPaginator
    
    public init(request: FollowersListRequest, paginator: StandardPaginator ) {
        self.init( userID: request.userID, paginator: paginator )
    }
    
    public init(userID: Int, paginator: StandardPaginator = StandardPaginator(pageNumber: 1, itemsPerPage: 30) ) {
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
