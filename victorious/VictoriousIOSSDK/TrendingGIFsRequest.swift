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
public struct TrendingGIFsRequest: Pageable {
    
    public let paginator: Paginator
    
    public init( request: TrendingGIFsRequest, paginator: Paginator ) {
        self.paginator = paginator
    }
    
    public init(pageNumber: Int = 1, itemsPerPage: Int = 15) {
        self.paginator = StandardPaginator(pageNumber: pageNumber, itemsPerPage: itemsPerPage)
    }
    
    public var urlRequest: NSURLRequest {
        let url = NSURL(string: "/api/image/trending_gifs")!
        let request = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(request)
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [GIFSearchResult] {
        guard let gifsJSON = responseJSON["payload"].array else {
            throw ResponseParsingError()
        }
        return gifsJSON.flatMap { GIFSearchResult(json: $0) }
    }
}
