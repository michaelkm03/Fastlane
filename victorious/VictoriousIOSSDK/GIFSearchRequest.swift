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
    public let searchTerm: String?
    
    public let paginator: StandardPaginator
    
    public init(request: GIFSearchRequest, paginator: StandardPaginator ) {
        self.init( searchTerm: request.searchTerm, paginator: paginator )
    }
    
    public init(searchTerm: String? = nil, paginator: StandardPaginator = StandardPaginator(pageNumber: 1, itemsPerPage: 20) ) {
		
		let url:  NSURL
		if let searchTerm = searchTerm {
			url = NSURL(string: "/api/image/gif_search")!.URLByAppendingPathComponent(searchTerm)!
		} else {
			url = NSURL(string: "/api/image/trending_gifs")!
		}
		
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
