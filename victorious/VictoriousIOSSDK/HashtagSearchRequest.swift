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
public struct HashtagSearchRequest: RequestType /* FIXME */{
    
    /// The search term to use when querying for hashtags
    public let searchTerm: String
    
    private let paginator: StandardPaginator
    
    public init(searchTerm: String, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.init(searchTerm: searchTerm, paginator: StandardPaginator(pageNumber: pageNumber, itemsPerPage: itemsPerPage))
    }
    
    private init(searchTerm: String, paginator: StandardPaginator) {
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
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> (results: [Hashtag], nextPage: HashtagSearchRequest?, previousPage: HashtagSearchRequest?) {
        
        let results = try HashtagResponseParser().parseResponse(responseJSON)
        
        let nextPageRequest: HashtagSearchRequest? = results.count > 0 ? HashtagSearchRequest(searchTerm: searchTerm, paginator: paginator.nextPage) : nil
        let previousPageRequest: HashtagSearchRequest?
        
        if let previousPage = paginator.previousPage {
            previousPageRequest = HashtagSearchRequest(searchTerm: searchTerm, paginator: previousPage)
        } else {
            previousPageRequest = nil
        }
        return (results, nextPageRequest, previousPageRequest)
    }
}
