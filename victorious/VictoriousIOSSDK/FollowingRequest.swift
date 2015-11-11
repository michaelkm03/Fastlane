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
    /// Users being followed will be retrieved by this user ID
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
        let url = NSURL(string: "/api/follow/subscribed_to_list/\(userID)")!
        let request = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(request)
        
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> (results: [User], nextPage: FollowingRequest?, previousPage: FollowingRequest?) {
        guard let usersJSON = responseJSON["payload"]["users"].array else {
            throw ResponseParsingError()
        }
        
        let results = usersJSON.flatMap { User(json: $0) }
        let nextPageRequest: FollowingRequest? = usersJSON.count > 0 ? FollowingRequest(userID: userID, paginator: paginator.nextPage) : nil
        let previousPageRequest: FollowingRequest?
        
        if let previousPage = paginator.previousPage {
            previousPageRequest = FollowingRequest(userID: userID, paginator: previousPage)
        } else {
            previousPageRequest = nil
        }
        return (results, nextPageRequest, previousPageRequest)
    }
}
