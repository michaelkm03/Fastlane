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
public struct GIFSearchRequest: Pageable {
    
    // A term to use when searching for GIFs
    public let searchTerm: String
    
    public let urlRequest: NSURLRequest
    
    private let paginator: StandardPaginator
    
    public init(searchTerm: String, pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.init(searchTerm: searchTerm, paginator: StandardPaginator(pageNumber: pageNumber, itemsPerPage: itemsPerPage))
    }
    
    private init(searchTerm: String, paginator: StandardPaginator) {
        
        let url = NSURL(string: "/api/image/gif_search")!.URLByAppendingPathComponent(searchTerm)
        let mutableURLRequest = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(mutableURLRequest)
        urlRequest = mutableURLRequest
        
        self.searchTerm = searchTerm
        self.paginator = paginator
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> (results: [GIFSearchResult], nextPage: GIFSearchRequest?, previousPage: GIFSearchRequest?) {
        
        guard let gifsJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        let results = gifsJSON.flatMap { GIFSearchResult(json: $0) }
        let nextPageRequest: GIFSearchRequest? = gifsJSON.count > 0 ? GIFSearchRequest(searchTerm: searchTerm, paginator: paginator.nextPage) : nil
        let previousPageRequest: GIFSearchRequest?
        
        if let previousPage = paginator.previousPage {
            previousPageRequest = GIFSearchRequest(searchTerm: searchTerm, paginator: previousPage)
        } else {
            previousPageRequest = nil
        }
        return (results, nextPageRequest, previousPageRequest)
    }
}
