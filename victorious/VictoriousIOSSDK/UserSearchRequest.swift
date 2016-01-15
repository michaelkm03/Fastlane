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
    
    public let searchTerm: String
    
    var context = SearchContext.Message
    
    public let paginator: StandardPaginator
    
    let url: NSURL
    
    public init(request: UserSearchRequest, paginator: StandardPaginator ) {
        self.searchTerm = request.searchTerm
        self.url = request.url
        self.paginator = paginator
    }

    // param: - searchTerm must be a urlPathPart percent encoded string
    public init?(searchTerm: String, paginator: StandardPaginator = StandardPaginator(pageNumber: 1, itemsPerPage: 50)) {
        
        let charSet = NSCharacterSet.vsdk_pathPartCharacterSet()
        guard let escapedSearchTerm = searchTerm.stringByAddingPercentEncodingWithAllowedCharacters(charSet),
            let url = NSURL(string: "/api/userinfo/search_paginate/\(escapedSearchTerm)") else {
                return nil
        }
        
        self.url = url
        self.searchTerm = searchTerm
        self.paginator = paginator
    }
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: url)
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
