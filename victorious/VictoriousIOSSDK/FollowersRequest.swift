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
public struct FollowersRequest: RequestType /* FIXME */{
    /// Followers will be retrieved by this user ID
    public let userID: Int64
    
    private let paginator: StandardPaginator
    
    public init(userID: Int64, pageNumber: Int = 1, itemsPerPage: Int = 40) {
        self.init(userID: userID, paginator: StandardPaginator(pageNumber: pageNumber, itemsPerPage: itemsPerPage))
    }
    
    private init(userID: Int64, paginator: StandardPaginator) {
        self.userID = userID
        self.paginator = paginator
    }
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string: "/api/follow/followers_list/\(userID)")!
        let request = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(request)
        
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> (results: [User], nextPage: FollowersRequest?, previousPage: FollowersRequest?) {
        guard let usersJSON = responseJSON["payload"]["users"].array else {
            throw ResponseParsingError()
        }
        
        let results = usersJSON.flatMap { User(json: $0) }
        let nextPageRequest: FollowersRequest? = usersJSON.count > 0 ? FollowersRequest(userID: userID, paginator: paginator.nextPage) : nil
        let previousPageRequest: FollowersRequest?
        
        if let previousPage = paginator.previousPage {
            previousPageRequest = FollowersRequest(userID: userID, paginator: previousPage)
        } else {
            previousPageRequest = nil
        }
        return (results, nextPageRequest, previousPageRequest)
    }
}
