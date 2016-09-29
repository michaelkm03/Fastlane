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
    
    public let urlRequest: URLRequest
    public let searchOptions: GIFSearchOptions
    
    public let paginator: StandardPaginator
    
    public init(request: GIFSearchRequest, paginator: StandardPaginator) {
        self.init(searchOptions: request.searchOptions, paginator: paginator)
    }
    
    public init(searchOptions: GIFSearchOptions, paginator: StandardPaginator = StandardPaginator(pageNumber: 1, itemsPerPage: 20)) {
		
		var url: URL?
        
        switch searchOptions {
            case .Search(let searchTerm, let searchURL):
                url = URL(string: searchURL)?.appendingPathComponent(searchTerm)
            case .Trending(let trendingURL):
                url = URL(string: trendingURL)
        }
        
        var request = URLRequest(url: url ?? URL(string: "")!)
        paginator.addPaginationArguments(to: &request)
        urlRequest = request
        
        self.searchOptions = searchOptions
        self.paginator = paginator
    }
    
    public func parseResponse(_ response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws -> [GIFSearchResult] {
        guard let gifsJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        return gifsJSON.flatMap { GIFSearchResult(json: $0) }
    }
}
