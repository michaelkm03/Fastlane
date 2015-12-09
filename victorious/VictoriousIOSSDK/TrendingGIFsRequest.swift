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
public struct TrendingGIFsRequest: PaginatorPageable, ResultBasedPageable {
    
    public let paginator: StandardPaginator
    
    public init( request: TrendingGIFsRequest, paginator: StandardPaginator ) {
        self.paginator = paginator
    }
    
    public init( paginator: StandardPaginator = StandardPaginator() ) {
        self.paginator = paginator
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
