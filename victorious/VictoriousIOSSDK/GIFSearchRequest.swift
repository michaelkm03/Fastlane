//
//  GIFSearchRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

/// Returns a list of GIFs based on a search query
public struct GIFSearchRequest: PaginatorPageable, ResultBasedPageable {
    
    public let urlRequest: NSURLRequest
    public let searchOptions: GIFSearchOptions
    
    public let paginator: StandardPaginator
    
    public init(request: GIFSearchRequest, paginator: StandardPaginator ) {
        self.init( searchOptions: request.searchOptions, paginator: paginator )
    }
    
    public init(searchOptions: GIFSearchOptions, paginator: StandardPaginator = StandardPaginator(pageNumber: 1, itemsPerPage: 20) ) {
		
//		let url:  NSURL
//		if let searchTerm = searchOptions.searchTerm {
//			url = NSURL(string: searchOptions.searchURL)!.URLByAppendingPathComponent(searchTerm)
//		} else {
//			url = NSURL(string: searchOptions.trendingURL)!
//		}
		
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL())
        paginator.addPaginationArgumentsToRequest(mutableURLRequest)
        urlRequest = mutableURLRequest
        
        self.searchOptions = searchOptions
        self.paginator = paginator
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [GIFSearchResult] {
        guard let gifsJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        return gifsJSON.flatMap { GIFSearchResult(json: $0) }
    }
}
