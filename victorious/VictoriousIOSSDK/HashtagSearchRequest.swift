//
//  HashtagSearchRequest.swift
//  victorious
//
//  Created by Patrick Lynch on 1/6/16.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct HashtagSearchRequest: PaginatorPageable, ResultBasedPageable {
    
    public let queryString: String
    
    var context = SearchContext.Message
    
    public let paginator: StandardPaginator
    
    public init(request: HashtagSearchRequest, paginator: StandardPaginator ) {
        self.queryString = request.queryString
        self.paginator = paginator
    }
    
    // param: - query must be a urlPathPart percent encoded string
    public init(query: String, paginator: StandardPaginator = StandardPaginator(pageNumber: 1, itemsPerPage: 50)) {
        self.queryString = query
        self.paginator = paginator
    }
    
    public var urlRequest: NSURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "/api/hashtag/search/\(queryString)")! )
        paginator.addPaginationArgumentsToRequest(request)
        let contextualURL = request.URL!.URLByAppendingPathComponent(context.rawValue)
        return NSURLRequest(URL: contextualURL)
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [Hashtag] {
        guard let hashtagStrings = responseJSON["payload"].rawValue as? [String] else {
            throw ResponseParsingError()
        }
        
        return hashtagStrings.flatMap { Hashtag(tag: $0) }
    }
}
