//
//  StickerSearchRequest.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

public struct StickerSearchRequest: PaginatorPageable, ResultBasedPageable {
    public let urlRequest: URLRequest
    public let searchOptions: AssetSearchOptions
    
    public let paginator: StandardPaginator
    
    public init(request: StickerSearchRequest, paginator: StandardPaginator) {
        self.init(searchOptions: request.searchOptions, paginator: paginator)
    }
    
    public init(searchOptions: AssetSearchOptions, paginator: StandardPaginator = StandardPaginator(pageNumber: 1, itemsPerPage: 20)) {
        
        let url: URL?
        switch searchOptions {
        case .search(let searchTerm, let searchURL):
            url = URL(string: searchURL)?.appendingPathComponent(searchTerm)
        case .trending(let trendingURL):
            url = URL(string: trendingURL)
        }
        
        // FUTURE: This should be failable initializer if url is nil
        let mutableURLRequest = URLRequest(url: url ?? URL(string: "foo")!)
        // FUTURE: Add proper pagination logic (replacing macros in the url)
        urlRequest = mutableURLRequest
        
        self.searchOptions = searchOptions
        self.paginator = paginator
    }
    
    public func parseResponse(_ response: URLResponse, toRequest request: URLRequest, responseData: Data, responseJSON: JSON) throws -> [StickerSearchResult] {
        guard let contentsJSON = responseJSON["payload"]["stickers"].array else {
            throw ResponseParsingError()
        }
        
        return contentsJSON.flatMap { StickerSearchResult(json: $0) }
    }
}
