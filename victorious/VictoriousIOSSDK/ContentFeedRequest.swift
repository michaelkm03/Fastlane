//
//  ContentFeedRequest.swift
//  victorious
//
//  Created by Vincent Ho on 5/17/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

public struct ContentFeedRequest: PaginatorPageable, ResultBasedPageable {
    
    public let paginator: StreamPaginator
    public let apiPath: String
    
    public init( apiPath: String, paginator: StreamPaginator? = nil ) {
        // NOTE: the ! on the following line will be replaced in a future PR which will move away from StreamPaginator. But for now, there is no reason it should ever return nil, as we will not have a macro replacement
        self.init( apiPath: apiPath, paginator: paginator ?? StreamPaginator(apiPath: apiPath)! )
    }
    
    public init( apiPath: String, paginator: StreamPaginator ) {
        self.paginator = paginator
        self.apiPath = apiPath
    }
    
    public init(request: ContentFeedRequest, paginator: StreamPaginator) {
        self.init(apiPath: request.apiPath, paginator: paginator)
    }
    
    public var urlRequest: NSURLRequest {
        let url = NSURL()
        let request = NSMutableURLRequest(URL: url)
        paginator.addPaginationArgumentsToRequest(request)
        return request
    }
    
    public func parseResponse(response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> [Content] {
        
        guard let contents = responseJSON["payload"]["viewed_contents"].array else {
            throw ResponseParsingError()
        }
        
        return contents.flatMap { Content(json: $0) }
    }
}
