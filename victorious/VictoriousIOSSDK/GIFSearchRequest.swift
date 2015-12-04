//
//  GIFSearchRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Returns a list of GIFs based on a search query
public struct GIFSearchRequest: Pageable, Searchable {
    
    public let urlRequest: NSURLRequest
    
    public let searchTerm: String
    
    public var paginator: PaginatorType
    
    public init(searchTerm: String, paginator: PaginatorType) {
        let url = NSURL(string: "/api/image/gif_search")!.URLByAppendingPathComponent(searchTerm)
        let mutableURLRequest = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(mutableURLRequest)
        urlRequest = mutableURLRequest
        
        self.searchTerm = searchTerm
        self.paginator = paginator
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [GIFSearchResult] {
        guard let gifsJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        return gifsJSON.flatMap { GIFSearchResult(json: $0) }
    }
}
