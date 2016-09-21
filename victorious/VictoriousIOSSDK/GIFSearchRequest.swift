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
    public let searchOptions: AssetSearchOptions
    
    public let paginator: StandardPaginator
    
    public init(request: GIFSearchRequest, paginator: StandardPaginator) {
        self.init(searchOptions: request.searchOptions, paginator: paginator)
    }
    
    public init(searchOptions: AssetSearchOptions, paginator: StandardPaginator = StandardPaginator(pageNumber: 1, itemsPerPage: 20)) {
		
		let url: NSURL?
        switch searchOptions {
            case .Search(let searchTerm, let searchURL):
                url = NSURL(string: searchURL)?.URLByAppendingPathComponent(searchTerm)
            case .Trending(let trendingURL):
                url = NSURL(string: trendingURL)
        }
        
        let mutableURLRequest = NSMutableURLRequest(URL: url ?? NSURL())
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
