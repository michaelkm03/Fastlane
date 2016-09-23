//
//  ContentSearchRequest.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct ContentSearchRequest: PaginatorPageable, ResultBasedPageable {
    public let urlRequest: NSURLRequest
    public let searchOptions: AssetSearchOptions
    
    public let paginator: StandardPaginator
    
    public init(request: ContentSearchRequest, paginator: StandardPaginator) {
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
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [Content] {
        guard let contentsJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        return contentsJSON.flatMap { Content(json: $0) }
    }
}
