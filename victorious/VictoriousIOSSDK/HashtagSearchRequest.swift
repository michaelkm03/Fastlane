//
//  HashtagSearchRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Retrieves a list of hashtags based on a search term
public struct HashtagSearchRequest: Pageable, Searchable {
    
    /// The search term to use when querying for hashtags
    public let searchTerm: String
    
    public let paginator: PaginatorType
    
    public init(searchTerm: String, paginator: PaginatorType) {
        self.searchTerm = searchTerm
        self.paginator = paginator
    }
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string: "/api/hashtag/search")!
        let request = NSMutableURLRequest(URL: url)
        request.URL = request.URL?.URLByAppendingPathComponent(searchTerm)
        paginator.addPaginationArgumentsToRequest(request)
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [Hashtag] {
        guard let hashtagJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        return hashtagJSON.flatMap { Hashtag(json: $0) }
    }
}
