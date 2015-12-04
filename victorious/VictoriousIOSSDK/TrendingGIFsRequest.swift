//
//  TrendingGIFsRequest.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 11/9/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Retrieves a list of trending GIFs
public struct TrendingGIFsRequest: RequestType /* FIXME */{
    
    private let paginator: StandardPaginator
    
    public init(pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.init(paginator: StandardPaginator(pageNumber: pageNumber, itemsPerPage: itemsPerPage))
    }
    
    private init(paginator: StandardPaginator) {
        self.paginator = paginator
    }
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string: "/api/image/trending_gifs")!
        let request = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(request)
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> (results: [GIFSearchResult], nextPage: TrendingGIFsRequest?, previousPage: TrendingGIFsRequest?) {
        
        guard let gifsJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        
        let results = gifsJSON.flatMap { GIFSearchResult(json: $0) }
        let nextPageRequest: TrendingGIFsRequest? = gifsJSON.count > 0 ? TrendingGIFsRequest(paginator: paginator.nextPage) : nil
        let previousPageRequest: TrendingGIFsRequest?
        
        if let previousPage = paginator.previousPage {
            previousPageRequest = TrendingGIFsRequest(paginator: previousPage)
        } else {
            previousPageRequest = nil
        }
        return (results, nextPageRequest, previousPageRequest)
    }
}
