//
//  UserSearchRequest.swift
//  victorious
//
//  Created by Michael Sena on 12/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct UserSearchRequest: PaginatorPageable, ResultBasedPageable {
    
    public let queryString: String
    
    var context = SearchContext.Message
    
    public let paginator: StandardPaginator
    
    public init(request: UserSearchRequest, paginator: StandardPaginator ) {
        self.queryString = request.queryString
        self.paginator = paginator
    }

    // param: - query must be a urlPathPart percent encoded string
    public init(query: String, paginator: StandardPaginator = StandardPaginator(pageNumber: 1, itemsPerPage: 50)) {
        self.queryString = query
        self.paginator = paginator
    }
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/userinfo/search_paginate/\(queryString)")!)
        paginator.addPaginationArgumentsToRequest(request)
        let contextualURL = request.URL!.URLByAppendingPathComponent(context.rawValue)
        return NSURLRequest(URL: contextualURL)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [User] {
        guard let usersJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        return usersJSON.flatMap { User(json: $0) }
    }
}
